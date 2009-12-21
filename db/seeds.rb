require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
include SeedMethods
UBIOTA        = "db/data/ubiota_taxonomy.psv.bz2"
ANAGE         = "db/data/anage.xml.bz2"
ANAGE_UBIOTA  = "db/data/hagrid_ubid.txt"

# Count the number of rows in a file.
def num_lines_bz2(filename)
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


def create_taxonomy
  # Remove any existing taxa
  puts "Removing any existing taxa..."
  Taxon.destroy_all

  # # Load new taxonomy information from UBioTa.
  progress "Loading seed data...", num_lines_bz2(UBIOTA) do |progress_bar|
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
def create_species
  new_species       = []
  orphaned_species  = []
  
  # Entrance message
  puts "** Creating new species from anage/ubiota files using hagrid_ubid as the bridge..."
  
  # Open files
  puts "** Opening data files..."
  anage         = IO.popen("bunzip2 -c #{ANAGE}")
  ubiota        = IO.popen("bunzip2 -c #{UBIOTA}")
  map           = IO.readlines(ANAGE_UBIOTA)
  anage && ubiota && map ? (puts "success") : (puts "*failed"; exit!)
  
  # Dump all species
  puts "** Removing any existing species..." 
  Species.destroy_all ? (puts "success") : (puts "failed"; exit!)
  
  # Load taxon from anage, let's use hpricot
  puts "** Loading anage data, let's use hpricot..."
  doc           = Hpricot::XML(anage)
  anage_species = (doc/'names')
  puts  "success: #{anage_species.size} species loaded"
  
  # Create new species and load anage attributes we want
  puts "** Loading species and storing anage data that we want..."
  anage_species.each do |s|
    x = {}
    x[:synonyms]  = (s/'name_common').inner_html
    new_species << x
  end
  puts "success: #{new_species.size} new species loaded in memory"
  
  # Load ubid into new species
  puts "** Loading ubid into new species..."
  map.each_with_index do |line, index|
    hagrid, ubid = line.split(/\s+/)
    new_species[index][:ubid] = ubid.to_i
  end
  puts "success"
  
  # Remove any species with no ubid
  count = new_species.size
  puts "** Delete any species that do not have a ubid mapped..."
  new_species.delete_if { |species| species[:ubid] == nil }
  puts "success: deleted #{count - new_species.size} species, #{new_species.size} remaining"
  
  # Sort species by ubid
  puts "** Sorting by ubid..."
  new_species = new_species.sort_by { |each| each[:ubid] }
  puts "success"
  
  # Find and load ubiota genus ids and species name for each species
  #   Ensure no the rank is 6 (species level) and that we don't run past all the 
  #   Set taxon_id to nil if the species inside ubiota doesn't exist   
  #   Species we have loaded, because we're incrementing through them
  puts "** Looking up and loading each species' genus id from the ubiota data (few minutes)..."
  x = 0    
  ubiota.each do |line|
  id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    break if new_species[x] == nil
    next  if rank.to_i != 6               
    while id.to_i > new_species[x][:ubid]
      new_species[x][:taxon_id] = nil
      orphaned_species << new_species[x]
      x += 1
    end       
    if new_species[x][:ubid] == id.to_i
      new_species[x][:taxon_id] = parent_id.to_i
      new_species[x][:name]     = term.to_s
      x += 1
    end
  end
  puts "success: traversed #{x} new species"
   
  # Remove any species that has no genus in ubiota 
  count = new_species.size
  puts "** Delete any species had no genus id or that are not species but rather taxon..."
  new_species.delete_if { |species| species[:taxon_id] == nil }
  puts "success: deleted #{count - new_species.size} species, #{new_species.size} remaining"
  
  # Create species with all the species stored in memory
  count   = 0
  fcount  = 0
  puts "** Saving all the species..."
  new_species.each_with_index do |s, index|
    taxon   = Taxon.find_by_id(s[:taxon_id])
    if taxon == nil
      puts "fail: no taxon found with and id of #{s[:taxon_id]} for species with ubid of #{s[:ubid]}"
      fcount += 1
    else
      species = Orgnism.new(:name => s[:name], :taxon_id => taxon.id, :synonyms => s[:synonyms])
      species.send(:create_without_callbacks)
      taxon   = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
      taxon.send(:create_without_callbacks)
    end
    count   = index
  end
  puts "success: Phew!... saved #{count - fcount} species"
  puts "failure: #{fcount} species didn't have taxons matching taxon_id in our database" if fcount != 0
  
  # Exit message
  puts "Species creation is completed"
end

# Execute taxonomy creation method
#create_taxonomy
# Execute species creation method
create_species
