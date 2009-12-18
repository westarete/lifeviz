require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
include SeedMethods
UBIOTA = "db/data/ubiota_taxonomy.psv.bz2"
ANAGE = "db/data/anage.xml.bz2"
ANAGE_UBIOTA = "db/data/hagrid_ubid.txt"

# Count the number of rows in a file.
def num_lines_bz2(filename)
  num_lines = 0
  puts "Calculating total size of job"
  IO.popen("bunzip2 -c #{filename}").each do |line|
    id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    next if rank == "rank"
    #break if rank == "6"
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

def create_species_revised
  new_species   = []
  
  # open files
  puts "Opening data files..."
  anage         = IO.popen("bunzip2 -c #{ANAGE}")
  ubiota        = IO.popen("bunzip2 -c #{UBIOTA}")
  map           = IO.readlines(ANAGE_UBIOTA)
  anage && map ? (puts "** success") : (puts "** failed")
  
  # dump all species
  puts "Removing any existing species..." 
  Species.destroy_all ? (puts "** success") : (puts "** failed")
  
  # load taxon from anage, let's use hpricot
  puts "Loading anage data, let's use hpricot..."
  doc           = Hpricot::XML(anage)
  anage_species = (doc/'names')
  puts  "** success: #{anage_species.size} species loaded"
  
  # create new species and load anage attributes we want
  puts "Loading species and storing anage data that we want..."
  anage_species.each do |s|
    x = {}
    x[:synonyms]  = (s/'name_common').inner_html
    new_species << x
  end
  puts "** success: #{new_species.size} new species loaded in memory"
  
  # Load ubid into new species
  puts "Loading ubid into new species..."
  map.each_with_index do |line, index|
    hagrid, ubid = line.split(/\s+/)
    new_species[index][:ubid] = ubid.to_i
  end
  puts "** success"
  
  # Remove any species with no ubid
  puts "Delete any species that do not have a ubid..."
  new_species.delete_if { |species| species[:ubid] == nil }
  puts "** success"
  
  # Sort species by ubid
  puts "Sorting by ubid..."
  new_species = new_species.sort_by { |each| each[:ubid] }
  puts "** success"
  
  # Find ubiota genus for each species and store load it
  puts "Looking up and loading each species' genus id in the ubiota data..."
  x = 0    
  ubiota.each do |line|
    id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    next if rank == "rank"
    if new_species[x][:ubid] == id.to_i
      new_species[x][:taxon_id] = parent_id.to_i
      x += 1
    end
  end
  puts "** success: traversed #{x} new species"

  # TEST PRINT OUT
  new_species.each do |x|
    puts "ubid: " + x[:ubid].to_s + ", taxon_id: " + x[:taxon_id].to_s + ", " + x[:synonyms].to_s 
  end
  
end


def create_species
  # Remove any existing species
  print "Removing any existing species..."
  Species.destroy_all
  puts " done."
  
  # Load species data from AnAge.
  print "Opening AnAge data..."
  doc = Hpricot::XML(IO.popen("bunzip2 -c #{ANAGE}"))
  animals = (doc/'names') # Grab all 'name' nodes with a 'species' node
  num_lines = animals.length
  puts " done."
  
  
  errors = []
  progress "Loading species...", num_lines do |progress_bar|
    animals.each do |animal|
      family = Taxon.find(:all, :conditions => ["name = ? AND rank = 4", (animal/'family').inner_html])
      if family.empty? # If family could not be found, the taxonomy at the family level isn't matching up.
        errors << "Could not find family: #{(animal/'family').inner_html} #{(animal/'genus').inner_html} #{(animal/'species').inner_html}"
      elsif family.length > 1 # 
        errors << "Too many matches: " + family.collect {|f| "#{f.name} "}.to_s
      else
        genus = Taxon.find(:first, :conditions => ["name = ? AND parent_id = ?", (animal/'genus').inner_html, family.id])
        if genus
          Species.create( :name => (animal/'name_common').inner_html,
                          :synonyms => (animal/'synonyms').inner_html,
                          :taxon => genus
                        )
        else
          errors << "Could not find genus that mached family: #{(animal/'family').inner_html} #{(animal/'genus').inner_html} #{(animal/'species').inner_html}"
        end
      end
      progress_bar.inc
    end
  end
  pp errors unless errors.empty?
  puts "Total rows: #{num_lines}"
  puts "Errors: #{errors.length}"
end

#create_taxonomy
create_species_revised









