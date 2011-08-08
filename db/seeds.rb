require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
require 'ruby-debug'
require 'benchmark'
include SeedMethods
UBIOTA          = "db/data/ubiota_taxonomy.psv.bz2"
LIFEVIZ         = "db/data/lifeviz.xml.bz2"
LIFEVIZ_UBIOTA  = "db/data/hagrid_ubid.txt"
LAKSHMI         = "db/data/names_import.psv.bz2"
MAXPLANK        = "db/data/maxplankdata.csv.bz2"
LIFESPANS       = "db/data/lifespans.csv.bz2"
LAKSHMI_USER  = User.find_or_create_by_name("Lakshmi",  :email => "lakshmi-noreply@mbl.edu",  :password => "B8%.GA{2LbV_N0!a7OjMqj17bHz3klS,2CsKAts7k3bsK<!=y", :password_confirmation => "B8%.GA{2LbV_N0!a7OjMqj17bHz3klS,2CsKAts7k3bsK<!=y")
ANAGE_USER    = User.find_or_create_by_name("Anage",    :email => "anage-noreply@mbl.edu",    :password => "B8%.GA{2LbV_N0!a7OjMqj17bHz3klS,2CsKAts7k3bsK<!=y", :password_confirmation => "B8%.GA{2LbV_N0!a7OjMqj17bHz3klS,2CsKAts7k3bsK<!=y")
MAXPLANK_USER = User.find_or_create_by_name("Maxplank", :email => "maxplank-noreply@mbl.edu", :password => "B8%.GA{2LbV_N0!a7OjMqj17bHz3klS,2CsKAts7k3bsK<!=y", :password_confirmation => "B8%.GA{2LbV_N0!a7OjMqj17bHz3klS,2CsKAts7k3bsK<!=y")
LAKSHMI_USER_ID    = LAKSHMI_USER.id
ANAGE_USER_ID      = ANAGE_USER.id
MAXPLANK_USER_ID   = MAXPLANK_USER.id
LAKSHMI_USER_NAME  = LAKSHMI_USER.name
ANAGE_USER_NAME    = ANAGE_USER.name
MAXPLANK_USER_NAME = MAXPLANK_USER.name
SQL = ActiveRecord::Base.connection();

def create_references
  # Remove any existing references
  seed "Removing any existing references and citations..." do
    Reference.delete_all ? true : false
  end

  seed "Setting reference id sequence back to 1" do
    (ActiveRecord::Base.connection.execute "SELECT setval('references_id_seq',1);") ? true : false
  end

  # Open files
  lifeviz = ""
  seed "Opening data files" do
    lifeviz = IO.popen("bunzip2 -c #{LIFEVIZ}")
  end

  # Load taxon from lifeviz, let's use hpricot
  lifeviz_refs = []
  seed "Loading lifeviz references" do
    doc = Hpricot::XML(lifeviz)
    lifeviz_refs = (doc/'biblio')
    (lifeviz_refs.size > 0)
  end
  notice "Created #{lifeviz_refs.size} references"

  progress "Storing refs", lifeviz_refs.length do |progress_bar|
    lifeviz_refs.each do |ref|
      newref = Reference.new
      newref.id        = (ref/'id_biblio').inner_html.to_i
      newref.pubmed_id = (ref/'pubmed').inner_html.to_i
      if newref.pubmed_id == 0
        newref.pubmed_id = nil
      end
      newref.title     = (ref/'title').inner_html
      newref.author    = (ref/'author').inner_html
      newref.publisher = (ref/'publisher').inner_html
      newref.year      = (ref/'year').inner_html
      newref.save!
      progress_bar.inc
    end
  end

  notice "#{lifeviz_refs.length} new references loaded in memory"
end

def create_taxonomy
  # Remove any existing taxa
  seed "Removing any existing taxa" do
    Taxon.delete_all
  end

  seed "Setting taxon id sequence back to 1" do
    ActiveRecord::Base.connection.execute "SELECT setval('taxa_id_seq',1);"
  end

  # Load new taxonomy information from UBioTa.
  progress "Load taxa", num_taxa_lines_bz2(UBIOTA) do |progress_bar|
    IO.popen("bunzip2 -c #{UBIOTA}").each do |line|
      id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
      next if rank == "rank"
      break if rank == "6"
      taxon = Taxon.new
      taxon['id'] = id.to_i
      taxon.name = term
      taxon.rank = rank.to_i
      if parent_id == "-1"
        taxon.parent_id = nil
      else
        taxon.parent_id = parent_id.to_i
      end
      taxon.send(:create_without_callbacks)
      progress_bar.inc
    end
  end

  seed "Resetting taxa id sequence" do
    lastval = ActiveRecord::Base.connection.execute "SELECT MAX(ID) FROM taxa;"
    newval = lastval.max["max"].to_i + 1
    ActiveRecord::Base.connection.execute "SELECT setval('taxa_id_seq', #{newval});"
  end
end

# Create species from lifeviz/ubiota using hagrid_ubid as the bridge
# Collect species data from Lifeviz
# Collect taxonomy species name and hierarchy from ubiota
def create_species_and_data
  # Entrance message
  puts "** Creating new species from lifeviz/ubiota files using hagrid_ubid as the bridge"
  puts "   Note! New species are species with data imported from lifeviz. Orphaned species "
  puts "   are ubiota species with no associated lifeviz data."
  new_species       = []
  orphaned_species  = []
  
  # Open files
  lifeviz, ubiota, map = nil
  seed "Opening data files" do
    lifeviz = IO.popen("bunzip2 -c #{LIFEVIZ}")
    ubiota  = IO.popen("bunzip2 -c #{UBIOTA}")
    map     = IO.readlines(LIFEVIZ_UBIOTA)
    lifeviz && ubiota && map ? true : false
  end

  # Dump all species
  seed "Removing existing species."
  progress "Deleting", Species.count do |progress_bar|
    Species.all.each do |species|
      species.delete
      progress_bar.inc
    end
  end

  # Dump all related data
  seed "Removing any existing age, litter sizes, adult weights, birth weights data" do
    Lifespan.delete_all && LitterSize.delete_all && AdultWeight.delete_all && BirthWeight.delete_all ? true : false
  end

  # Load taxon from lifeviz, let's use hpricot
  lifeviz_species, lifeviz_ages, lifeviz_development, lifeviz_refs = nil
  seed "Loading lifeviz data with hpricot" do
    doc                 = Hpricot::XML(lifeviz)
    lifeviz_species     = (doc/'names')
    lifeviz_ages        = (doc/'age')
    lifeviz_development = (doc/'development')
    lifeviz_refs        = (doc/'refs')
    (lifeviz_species.size > 0 && lifeviz_ages.size > 0 && lifeviz_development.size > 0 && lifeviz_refs.size > 0) ? true : false
  end
  notice "#{lifeviz_species.size} species loaded with #{lifeviz_ages.size} ages"

  # Create new species array to load lifeviz species and attributes we want
  seed "Loading new species and storing lifeviz data from lifeviz dump"
  development_index = ref_index = 0
  progress "Storing", lifeviz_species.length do |progress_bar|
    lifeviz_species.each_with_index do |s, index|
      hagrid        = (s/'id_hagr').inner_html.to_i
      x = {}
      x[:synonyms] = (s/'name_common').inner_html
      x[:age]      = (lifeviz_ages[index]/'tmax').inner_html
      x[:context]  = (lifeviz_ages[index]/'phenotype').inner_html
      x[:hagrid]   = hagrid
      x[:references] = x[:context].scan(/\[(\d*)\]/).flatten
      
      while lifeviz_development[development_index] && (lifeviz_development[development_index]/'hagrid').inner_html.to_i < hagrid
        notice "#{(lifeviz_development[development_index]/'hagrid').inner_html} is less than #{hagrid}"
        development_index += 1
      end
      # development attributes matches the current species id
      if lifeviz_development[development_index] && (lifeviz_development[development_index]/'hagrid').inner_html.to_i == hagrid
        development = lifeviz_development[development_index]
        if development && (development/'hagrid').inner_html.to_i == hagrid
          x[:adult_weight]  = (development/'adult_weight').inner_html.blank? ? "" : (development/'adult_weight').inner_html.to_f
          x[:birth_weight]  = (development/'birth_weight').inner_html.blank? ? "" : (development/'birth_weight').inner_html.to_f
          x[:litter_size]   = (development/'litter_size').inner_html.blank?  ? "" : (development/'litter_size').inner_html.to_f
        else
          x[:adult_weight]  = ""
          x[:birth_weight]  = ""
          x[:litter_size]   = ""
        end
        development_index += 1
      end
      new_species << x
      progress_bar.inc
    end
  end
  notice "#{new_species.length} new species stored"

  # Load ubid ids into new species from mapping
  seed "Loading mapped ubiota ids into new species" do
    new_species_pointer = 0
    map.each do |line|
      hagrid, ubid = line.split(/\s+/)
      while new_species[new_species_pointer] && hagrid.to_i != new_species[new_species_pointer][:hagrid]
        new_species_pointer += 1
      end
      new_species[new_species_pointer][:ubid] = ubid.to_i if new_species[new_species_pointer]
    end
  end

  # Remove any new species that have no ubid from mapping
  count = new_species.size
  seed "Delete any new species that do not have a ubiota id mapped", 
       :success => "Mappings completed", 
       :failure => "No species had mappings" do
    new_species.delete_if { |species| species[:ubid] == nil }
    new_species.length != 0 ? true : false
  end
  notice "deleted #{count - new_species.size} species, #{new_species.size} remaining"

  # Sort species by ubid
  seed "Sorting new species by ubid" do
    new_species = new_species.sort_by { |each| each[:ubid] }
    true
  end

  # Find and load ubiota genus ids and species name for each species
  #   Ensure the rank is 6 (species level)
  #   Set taxon_id to nil if the species inside ubiota doesn't exist
  seed "Looking up and loading each new species' genus id from the ubiota data"
  x = 0
  a_couple = 0
  num_lines = num_lines_bz2(UBIOTA)
  progress "Matching", num_lines do |progress_bar|
    ubiota.each do |line|
      id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
      # skip if we're not looking at a species level taxon
      if rank.to_i != 6
        progress_bar.inc
        next
      end
      if new_species[x].nil? || id.to_i != new_species[x][:ubid]
        y = {:taxon_id => parent_id.to_i, :name => term.to_s}
        orphaned_species << y
        if !new_species[x].nil? then new_species[x][:taxon_id] = nil end
        if !new_species[x].nil? && id.to_i > new_species[x][:ubid] then x += 1 end
      else
        new_species[x][:taxon_id] = parent_id.to_i
        new_species[x][:name]     = term.to_s
        x += 1
      end
      progress_bar.inc
    end
  end
  notice "traversed #{x} new species and #{orphaned_species.size} orphaned species"

  # Remove any new species that has no genus in ubiota
  count = new_species.size
  seed "Delete any species that had no genus id" do
    new_species.delete_if { |species| species[:taxon_id] == nil }
  end
  notice success_string("deleted #{count - new_species.size} species, #{new_species.size} remaining")

  # Remove any orphaned species that has no genus in ubiota
  count = orphaned_species.size
  seed "Delete any orphaned species that had no genus id" do
    orphaned_species.delete_if { |species| species[:taxon_id] == 0 }
  end
  notice success_string("deleted #{count - orphaned_species.size} species, #{orphaned_species.size} remaining")

  # Create species with all the new species stored in memory
  count = species_without_parents = 0
  seed "Saving all of the new species."

  progress "Species", new_species.length do |progress_bar|
    new_species.each_with_index do |taxon, index|
      s = new_species[index]
      species = Taxon.new(:name => s[:name], :parent_id => s[:taxon_id], :rank => 6, :id => s[:ubid])
      species.send(:create_without_callbacks)
      # # This was commented out because we're using Cera's lifespan data now.
      # unless s[:age].blank?
      #   s[:references].each do |reference_id|
      #     lifespan = Lifespan.new(:value_in_days => (s[:age].to_f * 365), :units => "Years", :species_id => species.id)
      #     lifespan.context = s[:context]
      #     lifespan.citation = Reference.find(reference_id).to_s
      #     lifespan.created_by = ANAGE_USER_ID
      #     lifespan.created_by_name = ANAGE_USER_NAME
      #     lifespan.send(:create_without_callbacks)
      #   end
      # end
      BirthWeight.new(
        :value_in_grams => (s[:birth_weight]),
        :units => "Grams",
        :species_id => species.id,
        :created_by => ANAGE_USER_ID,
        :created_by_name => ANAGE_USER_NAME
      ).send(:create_without_callbacks) unless s[:birth_weight].blank?
      AdultWeight.new(
        :value_in_grams => (s[:adult_weight]),
        :units => "Grams",
        :species_id => species.id,
        :created_by => ANAGE_USER_ID,
        :created_by_name => ANAGE_USER_NAME
      ).send(:create_without_callbacks) unless s[:adult_weight].blank?
      LitterSize.new (
        :value => (s[:litter_size]),
        :species_id => species.id,
        :created_by => ANAGE_USER_ID,
        :created_by_name => ANAGE_USER_NAME
      ).send(:create_without_callbacks) unless s[:litter_size].blank?
      count = index
      progress_bar.inc
    end
  end
  notice success_string("saved #{count - species_without_parents} species")
  notice success_string("saved #{Lifespan.count} ages")
  notice success_string("saved #{AdultWeight.count} adult weights")
  notice success_string("saved #{BirthWeight.count} birth weights")
  notice success_string("saved #{LitterSize.count} litter sizes")
  notice failure_string("#{species_without_parents} species didn't have taxons matching taxon_id in our database") if species_without_parents != 0

  # Create orphaned species with all the species stored in memory
  count   = 0
  species_without_parents  = 0
  seed "Saving all the orphaned species"
  progress "Saving orphans", orphaned_species.length do |progress_bar|
    orphaned_species.each_with_index do |s, index|
      taxon   = Taxon.find_by_id(s[:taxon_id])
      if taxon == nil
       # notice failure_string("no taxon found with an id of #{s[:taxon_id].to_s} for species with ubid of #{s[:ubid].to_s}")
       species_without_parents += 1
      else
       species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
       species.send(:create_without_callbacks)
      end
      count = index
      progress_bar.inc
    end
  end
  notice success_string("Phew!... saved #{count - species_without_parents} species")
  notice failure_string("#{species_without_parents} species didn't have taxons matching taxon_id in our database") if species_without_parents != 0

  seed "Rebuilding heirarchical tree" do
    Taxon.rebuild!
  end

  seed "Vacuuming database" do
    SQL.execute "VACUUM ANALYZE;"
  end

  notice "Species creation is completed."
end

def rebuild_lineages
  
  SQL.begin_db_transaction
  # Clear all lineage_ids
  seed "Clearing existing lineage data" do
    SQL.execute "alter table taxa drop column lineage_ids;"
    SQL.execute "alter table taxa add column lineage_ids varchar(255);"
  end
  seed "Rebuilding lineages", :success => "#{Taxon.count} taxa set" do
    Taxon.rebuild_lineages!
    true
  end
  SQL.commit_db_transaction
end

def vacuum_database
  seed "Vacuuming database" do
    SQL.execute "VACUUM ANALYZE;"
  end
end

def import_lakshmi
  lakshmi = nil
  seed "Opening lakshmi data" do
    lakshmi = IO.popen("bunzip2 -c #{LAKSHMI}")
    lakshmi ? true : false
  end
  
  seed "Saving annotations from Lakshmi's dataset"
  number_of_lines = num_lines_bz2(LAKSHMI)
  species_annotations = 0
  taxon_annotations = 0
  misses = 0
  progress "Lakshmi", number_of_lines do |progress_bar|
    lakshmi.each do |line|
      ubiota_id, lifespan_in_days, citation, citation_url, sentence, verbatim_name_string, url = line.split("|")
      if species = Taxon.find(:first, :conditions => {:id => ubiota_id.to_i})
        Lifespan.create(:value_in_days => lifespan_in_days, :units => "Days", :species_id => species.id, :citation => citation, :context => sentence, :created_by => LAKSHMI_USER_ID, :created_by_name => LAKSHMI_USER_NAME)
        if species.rank == 6
          species_annotations += 1
        else
          taxon_annotations += 1
        end
      else
        # notice failure_string("Couldn't find taxon #{ubiota_id}")
        misses += 1
      end
      progress_bar.inc
    end
  end
  notice success_string("Saved #{species_annotations} species annotations and #{taxon_annotations} taxon annotations.")
  notice failure_string("Couldn't find #{misses} ubiota ids.")
end

def import_maxplank
  maxplank = nil
  seed "Opening maxplank data" do
    maxplank = IO.popen("bunzip2 -c #{MAXPLANK}")
    maxplank ? true : false
  end
  
  seed "Saving annotations from the 'maxplankdata' dataset"
  number_of_lines = num_lines_bz2(LAKSHMI)
  species_annotations = 0
  taxon_annotations = 0
  misses = 0
  progress "Maxplank", number_of_lines do |progress_bar|
    maxplank.each do |line|
      ubiota_id, lifespan_in_days, citation = line.split(",")
      if species = Taxon.find(:first, :conditions => {:id => ubiota_id.to_i})
        Lifespan.create(:value_in_days => lifespan_in_days, :units => "Days", :species_id => species.id, :citation => citation, :created_by => MAXPLANK_USER_ID, :created_by_name => MAXPLANK_USER_NAME)
        if species.rank == 6
          species_annotations += 1
        else
          taxon_annotations += 1
        end
      else
        # notice failure_string("Couldn't find taxon #{ubiota_id}")
        misses += 1
      end
      progress_bar.inc
    end
  end
  notice success_string("Saved #{species_annotations} species annotations and #{taxon_annotations} taxon annotations.")
  notice failure_string("Couldn't find #{misses} ubiota ids.")
end

def import_lifespans
  lifespans = nil
  seed "Opening lifespan data" do
    lifespans = IO.popen("bunzip2 -c #{LIFESPANS}")
    lifespans ? true : false
  end
  
  seed "Saving lifespans from Cera's modifications"
  number_of_lines = num_lines_bz2(LIFESPANS)
  failures = 0
  successes = 0
  progress "Lifespan", number_of_lines do |progress_bar|
    lifespans.each_with_index do |line, i|
      _, species_id, _, _, value_in_days, units, _, _, citation, context, reliable = FasterCSV.parse(line)[0]
      lifespan = Lifespan.new
      lifespan.species_id = species_id.to_i
      lifespan.value_in_days = value_in_days.to_f
      lifespan.units = units
      lifespan.citation = citation
      lifespan.context = context
      lifespan.created_by = ANAGE_USER
      lifespan.save ? successes += 1 : failures += 1
      progress_bar.inc
    end
  end
  
  notice success_string("Saved #{successes} new lifespans successfully.")
  notice failure_string("Failed to save #{failures} lifespans. Probably missing values!")
end

def create_statistics
  seed "Deleting existing statistics objects" do
    Statistics.delete_all
    true
  end

  seed "Calculating species statistics" do
    Species.rebuild_stats
  end
  
  seed "Calculating other taxa statistics" do
    Taxon.rebuild_stats
  end
  
  # Create statistics records with no data.
  seed "Create 'ghost' statistics records" do
    ActiveRecord::Base.connection.execute("
      INSERT INTO statistics
        SELECT
          taxa.id as id,
          taxa.id as taxon_id
        FROM taxa
          LEFT OUTER JOIN statistics
            ON taxa.id = statistics.taxon_id
          WHERE statistics.id IS NULL;
    ")
  end

  notice "Finished calculating statistics."
end

seed_section("Create References", Proc.new{create_references})
seed_section("Create Taxonomy", Proc.new{create_taxonomy})
seed_section("Create Species and Anage Data", Proc.new{create_species_and_data})  # Must be run after create_taxonomy
seed_section("Rebuild Lineages", Proc.new{rebuild_lineages})
seed_section("Import Lakshmi's Dataset", Proc.new{import_lakshmi})
seed_section("Import 'Maxplank' Data", Proc.new{import_maxplank})
seed_section("Import Cera's lifespan data", Proc.new{import_lifespans})
seed_section("Create Statistics", Proc.new{create_statistics})
