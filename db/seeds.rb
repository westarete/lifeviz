require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
require 'ruby-debug'
include SeedMethods
UBIOTA          = "db/data/ubiota_taxonomy.psv.bz2"
LIFEVIZ         = "db/data/lifeviz.xml.bz2"
LIFEVIZ_UBIOTA  = "db/data/hagrid_ubid.txt"

# Count the number of taxa in a file.
def num_taxa_lines_bz2(filename)
  returning num_lines = 0 do
    IO.popen("bunzip2 -c #{filename}").each do |line|
      id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
      next if rank  == "rank"
      break if rank == "6"
      num_lines += 1
    end
  end
end

# Count the number of rows in a file.
def num_lines_bz2(filename)
  returning num_lines = 0 do
    IO.popen("bunzip2 -c #{filename}").each do |line|
      num_lines += 1
    end
  end
end

def create_references
  # Remove any existing references
  seed "Removing any existing references and citations..." do
    Citation.delete_all && Reference.delete_all ? true : false
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

def rebuild_lineages
  sql = ActiveRecord::Base.connection();
  sql.begin_db_transaction
  # Clear all lineage_ids
  seed "Clearing existing lineage data" do
    sql.execute "alter table taxa drop column lineage_ids;"
    sql.execute "alter table taxa add column lineage_ids varchar(255);"
  end
  seed "Rebuilding lineages", :success => "#{Taxon.count} taxa set" do
    Taxon.rebuild_lineages!
    true
  end
  sql.commit_db_transaction
end

# Create species from lifeviz/ubiota using hagrid_ubid as the bridge
# Collect species data from Lifeviz
# Collect taxonomy species name and hierarchy from ubiota
def create_species_and_data
  # Entrance message
  puts "** Creating new species from lifeviz/ubiota files using hagrid_ubid as the bridge"
  puts "   Note! New species are species with data imported from lifeviz. Orphaned species "
  puts "   are ubiota species with no associated lifeviz data."
  sql = ActiveRecord::Base.connection();
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
      x[:hagrid]   = hagrid
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
      while lifeviz_refs[ref_index] && (lifeviz_refs[ref_index]/'hagrid').inner_html.to_i < hagrid
        notice "#{(lifeviz_refs[ref_index]/'hagrid').inner_html} is less than #{hagrid}"
        ref_index += 1
      end
      if lifeviz_refs[ref_index]
        x[:references] = []
        while lifeviz_refs[ref_index] && (lifeviz_refs[ref_index]/'hagrid').inner_html.to_i == hagrid
          x[:references] << (lifeviz_refs[ref_index]/'id_biblio').inner_html.to_i
          ref_index += 1
        end
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
      species = Taxon.new(:name => s[:name], :parent_id => s[:taxon_id], :rank => 6)
      species.send(:create_without_callbacks)
      Lifespan.new(:value_in_days => (s[:age].to_f * 365), :units => "Years", :species_id => species.id).send(:create_without_callbacks)   unless s[:age].blank?
      BirthWeight.new(:value_in_grams => (s[:birth_weight]), :units => "Grams", :species_id => species.id).send(:create_without_callbacks) unless s[:birth_weight].blank?
      AdultWeight.new(:value_in_grams => (s[:adult_weight]), :units => "Grams", :species_id => species.id).send(:create_without_callbacks) unless s[:adult_weight].blank?
      LitterSize.new(:value => (s[:litter_size]), :species_id => species.id).send(:create_without_callbacks) unless s[:litter_size].blank?
      s[:references].each {|reference_id| Citation.create(:taxon_id => species.id, :reference_id => reference_id) }
      count = index
      progress_bar.inc
    end
  end
  notice success_string("saved #{count - species_without_parents} species")
  notice success_string("saved #{Lifespan.count} ages")
  notice success_string("saved #{AdultWeight.count} adult weights")
  notice success_string("saved #{BirthWeight.count} birth weights")
  notice success_string("saved #{LitterSize.count} litter sizes")
  notice success_string("saved #{Citation.count} citations for #{Reference.count} references")
  notice failure_string("#{species_without_parents} species didn't have taxons matching taxon_id in our database") if species_without_parents != 0

  # # Create orphaned species with all the species stored in memory
  # count   = 0
  # species_without_parents  = 0
  # seed "Saving all the orphaned species"
  # progress "Saving orphans", orphaned_species.length do |progress_bar|
  #   orphaned_species.each_with_index do |s, index|
  #     taxon   = Taxon.find_by_id(s[:taxon_id])
  #     if taxon == nil
  #      notice failure_string("no taxon found with an id of #{s[:taxon_id].to_s} for species with ubid of #{s[:ubid].to_s}")
  #      species_without_parents += 1
  #     else
  #      species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
  #      # species.send(:create_without_callbacks)
  #     end
  #     count = index
  #     progress_bar.inc
  #   end
  # end
  # notice success_string("Phew!... saved #{count - species_without_parents} species")
  # notice failure_string("#{species_without_parents} species didn't have taxons matching taxon_id in our database") if species_without_parents != 0

  seed "Rebuilding heirarchical tree" do
    Taxon.rebuild!
  end

  seed "Vacuuming database" do
    sql.execute "VACUUM ANALYZE;"
  end

  notice "Species creation is completed."
end

def create_statistics
  number_of_statistics = nil
  seed "Creating statistics objects" do
    Taxon.rebuild_statistics_objects
    number_of_statistics = Statistics.count
    true
  end
  notice "#{number_of_statistics} objects created"

  seed "Calculating statistics" do
    Taxon.rebuild_stats
  end

  notice "Finished calculating statistics."
end

# create_references
# create_taxonomy
# create_species_and_data  # Must be run after create_taxonomy
# rebuild_lineages
create_statistics
