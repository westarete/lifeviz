require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
require 'ruby-debug'
include SeedMethods
UBIOTA        = "db/data/ubiota_taxonomy.psv.bz2"
ANAGE         = "db/data/anage.xml.bz2"
ANAGE_UBIOTA  = "db/data/hagrid_ubid.txt"

# Count the number of taxa in a file.
def num_taxa_lines_bz2(filename)
  num_lines = 0
  puts "Calculating total size of job"
  IO.popen("bunzip2 -c #{filename}").each do |line|
    id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    next if rank == "rank"
    break if rank == "6"
    num_lines += 1
  end
  num_lines
end

# Count the number of rows in a file.
def num_lines_bz2(filename)
  num_lines = 0
  puts "Calculating total size of job"
  IO.popen("bunzip2 -c #{filename}").each do |line|
    num_lines += 1
  end
  num_lines
end

def create_taxonomy
  # Remove any existing taxa
  puts "Removing any existing taxa..."
  Taxon.delete_all
  
  puts "Setting taxon id sequence back to 1"
  ActiveRecord::Base.connection.execute "SELECT setval('taxa_id_seq',1);"

  # Load new taxonomy information from UBioTa.
  progress "Loading seed data...", num_taxa_lines_bz2(UBIOTA) do |progress_bar|
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
  
  lastval = ActiveRecord::Base.connection.execute "SELECT MAX(ID) FROM taxa;"
  newval = lastval.max["max"].to_i + 1
  ActiveRecord::Base.connection.execute "SELECT setval('taxa_id_seq', #{newval});"
end

def rebuild_lineages
  sql = ActiveRecord::Base.connection();
	sql.begin_db_transaction
	
  # Clear all lineage_ids
  puts "** Clearing existing lineage data..."
  sql.execute "UPDATE taxa SET lineage_ids = NULL;"
  puts "success"
  
  Taxon.rebuild_lineages!
  
  puts  "success: #{Taxon.count} taxa set"
  sql.commit_db_transaction
end

# Create species from anage/ubiota using hagrid_ubid as the bridge
# Collect species data from Anage
# Collect taxonomy species name and hierarchy from ubiota
def create_species_and_data
  new_species       = []
  orphaned_species  = []
  
  # Entrance message
  puts "** Creating new species from anage/ubiota files using hagrid_ubid as the bridge"
  puts " NOTE: new species are species with data imported from anage, orphaned species are "
  puts "       ubiota species with no associated anage data"
  
  # Open files
  puts "** Opening data files..."
  anage         = IO.popen("bunzip2 -c #{ANAGE}")
  ubiota        = IO.popen("bunzip2 -c #{UBIOTA}")
  map           = IO.readlines(ANAGE_UBIOTA)
  anage && ubiota && map ? (puts "success") : (puts "*failed"; exit!)

  # Dump all related data
  puts "** Removing any existing age, litter sizes, adult weights,birth weights data..." 
  Lifespan.destroy_all && LitterSize.destroy_all && AdultWeight.destroy_all && BirthWeight.destroy_all ? (puts "success") : (puts "failed"; exit!)
  
  # Load taxon from anage, let's use hpricot
  puts "** Loading anage data, let's use hpricot..."
  doc               = Hpricot::XML(anage)
  anage_species     = (doc/'names')
  anage_ages        = (doc/'age')
  anage_development = (doc/'development')
  puts  "success: #{anage_species.size} species loaded with #{anage_ages.size} ages}"
  
  puts "anage species: #{anage_species.size}, anage ages: #{anage_ages.size}, anage devs: #{anage_development.size}"
    
  # Create new species array to load anage species and attributes we want
  puts "** Loading new species and storing anage data from anage dump..."
  development_index = 0
  progress "Storing data", anage_species.length do |progress_bar|
    anage_species.each_with_index do |s, index|
      hagrid        = (s/'id_hagr').inner_html
      x = {}
      x[:synonyms]  = (s/'name_common').inner_html
      x[:age]       = (anage_ages[index]/'tmax').inner_html
      x[:hagrid]    = hagrid

      while anage_development[development_index] && (anage_development[development_index]/'hagrid').inner_html.to_i < hagrid.to_i
        puts "#{(anage_development[development_index]/'hagrid').inner_html} is less than #{hagrid}"
        development_index += 1
      end
      
      # development attributes matches the current species id
      if anage_development[development_index] && (anage_development[development_index]/'hagrid').inner_html.to_i == hagrid.to_i
        development = anage_development[development_index]
        if development && (development/'hagrid').inner_html == hagrid
          x[:adult_weight]  = (development/'adult_weight').inner_html.to_f
          x[:birth_weight]  = (development/'birth_weight').inner_html.to_f
          x[:litter_size]   = (development/'litter_size').inner_html.to_f
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

  puts "success: #{new_species.size} new species loaded in memory"
    
  # Load ubid ids into new species from mapping
  puts "** Loading mapped ubiota ids into new species..."
  new_species_pointer = 0
  map.each do |line|
    hagrid, ubid = line.split(/\s+/)
    while hagrid != new_species[new_species_pointer][:hagrid]
      new_species_pointer += 1
    end
    new_species[new_species_pointer][:ubid] = ubid.to_i
  end
  puts "success"
  
  # Remove any new species that have no ubid from mapping
  count = new_species.size
  puts "** Delete any new species that do not have a ubiota id mapped..."
  new_species.delete_if { |species| species[:ubid] == nil }
  puts "success: deleted #{count - new_species.size} species, #{new_species.size} remaining"
  
  # Sort species by ubid
  puts "** Sorting new species by ubid..."
  new_species = new_species.sort_by { |each| each[:ubid] }
  puts "success"
  
  # Find and load ubiota genus ids and species name for each species
  #   Ensure the rank is 6 (species level)
  #   Set taxon_id to nil if the species inside ubiota doesn't exist
  puts "** Looking up and loading each new species' genus id from the ubiota data (few minutes)..."
  x = 0
  a_couple = 0
  progress "Loading seed data...", num_lines_bz2(UBIOTA) do |progress_bar|
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
  puts "success: traversed #{x} new species and #{orphaned_species.size} orphaned species"
   
  # Remove any new species that has no genus in ubiota 
  count = new_species.size
  puts "** Delete any species that had no genus id... (NOTE THIS)"
  new_species.delete_if { |species| species[:taxon_id] == nil }
  puts "success: deleted #{count - new_species.size} species, #{new_species.size} remaining"
  
  # Remove any orphaned species that has no genus in ubiota 
  count = orphaned_species.size
  puts "** Delete any orphaned species that had no genus id... (NOTE THIS)"
  orphaned_species.delete_if { |species| species[:taxon_id] == 0 }
  puts "success: deleted #{count - orphaned_species.size} species, #{orphaned_species.size} remaining"

  # Create species with all the new species stored in memory
  count   = 0
  fcount  = 0
  age_nil = 0
  birth_weight_nil = 0
  adult_weight_nil = 0
  litter_size_nil  = 0
  puts "** Saving all the new species..."
  start_time = Time.now
  progress "Species", new_species.length do |progress_bar|
    new_species.each_with_index do |s, index|
      taxon   = Taxon.find_by_id(s[:taxon_id])
      if taxon.nil?
        fcount += 1
      else
        species = Taxon.find_by_name(s[:name])
        if species.nil?
          species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
          species.send(:create_without_callbacks)
        end
        
        age          = Lifespan.new(:value_in_days => (s[:age].to_f * 365), :units => "Years", :species_id => species.id)   if ! s[:age].blank?
        birth_weight = BirthWeight.new(:value_in_grams => (s[:birth_weight]), :units => "Grams", :species_id => species.id) if ! s[:birth_weight].blank?
        adult_weight = AdultWeight.new(:value_in_grams => (s[:adult_weight]), :units => "Grams", :species_id => species.id) if ! s[:adult_weight].blank?
        litter_size  = LitterSize.new(:measure => (s[:litter_size]), :species_id => species.id) if ! s[:litter_size].blank?
        
        age.nil?          ? (age_nil += 1) : age.send(:create_without_callbacks)
        adult_weight.nil? ? (adult_weight_nil += 1) : adult_weight.send(:create_without_callbacks)
        birth_weight.nil? ? (birth_weight_nil += 1) : birth_weight.send(:create_without_callbacks)
        litter_size.nil?  ? (litter_size_nil += 1)  : litter_size.send(:create_without_callbacks)

      end
      count = index
      progress_bar.inc
    end
  end
  puts "success: saved #{count - fcount} species in #{Time.now - start_time}"
  puts "success: saved #{count - age_nil} ages"
  puts "success: saved #{count - adult_weight_nil} adult weights"
  puts "success: saved #{count - birth_weight_nil} birth weights"
  puts "success: saved #{count - litter_size_nil} litter sizes"
  
  puts "failure: #{fcount} species didn't have taxons matching taxon_id in our database" if fcount != 0
  
  # Create orphaned species with all the species stored in memory
  count   = 0
  fcount  = 0
  puts "** Saving all the orphaned species..."
  progress "Orphans", orphaned_species.length do |progress_bar|
    orphaned_species.each_with_index do |s, index|
      taxon   = Taxon.find_by_id(s[:taxon_id])
      if taxon == nil
       puts "fail: no taxon found with and id of #{s[:taxon_id].to_s} for species with ubid of #{s[:ubid].to_s}"
       fcount += 1
      else
       species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
       # species.send(:create_without_callbacks)
      end
      count = index
      progress_bar.inc
    end
  end
  puts "success: Phew!... saved #{count - fcount} species"  
  puts "failure: #{fcount} species didn't have taxons matching taxon_id in our database" if fcount != 0
  
  # Exit message
  puts "Species creation is completed"
  puts "NOTE: don't forget to run Taxon.rebuild! ... it will take a while & vacuum analyze"
end

# Execute taxonomy creation method
create_taxonomy
# Execute species creation method
create_species_and_data
rebuild_lineages