require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
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

  # # Load new taxonomy information from UBioTa.
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
#   Collect species data from Anage
#   Collect taxonomy species name and hierarchy from ubiota
#   Author: john marino
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
  puts "** Removing any existing age data..." 
  # Age.destroy_all ? (puts "success") : (puts "failed"; exit!)
  
  # Load taxon from anage, let's use hpricot
  puts "** Loading anage data, let's use hpricot..."
  doc           = Hpricot::XML(anage)
  anage_species = (doc/'names')
  anage_ages    = (doc/'age')
  
  puts  "success: #{anage_species.size} species loaded with #{anage_ages.size} ages"
  
  # Create new species array to load anage species and attributes we want
  puts "** Loading new species and storing anage data from anage dump..."
  progress "Storing data", anage_species.length do |progress_bar|
    anage_species.each_with_index do |s, index|
      x = {}
      x[:synonyms]  = (s/'name_common').inner_html
      x[:age]       = (anage_ages[index]/'tmax').inner_html
      new_species << x
      progress_bar.inc
    end
  end
  puts "success: #{new_species.size} new species loaded in memory"
    
  # Load ubid ids into new species from mapping
  puts "** Loading mapped ubiota ids into new species..."
  map.each_with_index do |line, index|
    hagrid, ubid = line.split(/\s+/)
    new_species[index][:ubid] = ubid.to_i
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
    
        # if y[:taxon_id] == 0
        #   puts "id: #{id} term: #{term} rank: #{rank} parentid: #{parent_id}"; a_couple += 1
        #   puts line
        #   puts"\n"
        # end
        # # DEBUGGER
        # if a_couple == 20 then raise "investigate" end
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
  puts "** Saving all the new species..."
  start_time = Time.now
  progress "Species", new_species.length do |progress_bar|
    new_species.each_with_index do |s, index|
      taxon   = Taxon.find_by_id(s[:taxon_id])
      if taxon == nil
        puts "fail: no taxon found with and id of #{s[:taxon_id]} for species with ubid of #{s[:ubid]}"
        fcount += 1
      else
        species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
        species.send(:create_without_callbacks)
        age     = Lifespan.new(:value_in_days => (s[:age].to_f * 365), :units => "Years", :species_id => species.id)
        
        if age.value_in_days == 0
          age_nil += 1
        else
          age.send(:create_without_callbacks)
        end
      end
      count = index
      progress_bar.inc
    end
  end
  puts "success: Phew!... saved #{count - fcount} species in #{Time.now - start_time}"
  puts "success: Phew!... saved #{count - age_nil} ages"
  
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
       species.send(:create_without_callbacks)
      end
      count = index
      progress_bar.inc
    end
  end
  puts "success: Phew!... saved #{count - fcount} species"  
  puts "failure: #{fcount} species didn't have taxons matching taxon_id in our database" if fcount != 0

  # Exit message
  puts "Species creation is completed"
  
  puts "NOTE: don't forget to run Taxon.rebuild! ... it will take a while"
end

# Execute taxonomy creation method
create_taxonomy
# Execute species creation method
create_species_and_data
# rebuild_lineages
