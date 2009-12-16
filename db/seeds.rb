require 'progressbar'
require 'db/seed_methods'
require 'hpricot'
require 'pp'
include SeedMethods
UBIOTA = "db/data/ubiota_taxonomy.psv.bz2"
ANAGE = "db/data/anage.xml.bz2"

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
        genus = family[0].find(:first, :conditions => ["name = ?", (animal/'genus').inner_html])
        if genus
          Species.create( :name => (animal/'name_common').inner_html,
                          :synonyms => (animal/'synonyms').inner_html,
                          :taxon => genus
                        )
        else
          errors << "Could not find genus that mached family: #{(animal/'family').inner_html} #{(animal/'genus').inner_html} #{(animal/'species').inner_html}"
        end
      enda
      progress_bar.inc
    end
  end
  pp errors unless errors.empty?
  puts "Total rows: #{num_lines}"
  puts "Errors: #{errors.length}"
end

# create_taxonomy
create_species
