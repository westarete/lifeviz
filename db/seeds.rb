require 'progressbar'
require 'db/seed_methods'
include SeedMethods
UBIOTA = "db/data/ubiota_taxonomy.psv"
ANAGE = "db/data/anage.xml"


# Count the number of rows in a file.
def num_lines(filename)
  num_lines = 0
  File.open(filename).each do |line|
    id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    next if rank == "rank"
    break if rank == "6"
    num_lines += 1
  end
  num_lines
end


# DESTROY ALL TAXONOMY! BUAH HUA HA HA HAHAHAHAHA
print "Destroying all taxonomy..."
Taxon.destroy_all
puts "done."

# Load new taxonomy information from UBioTa.
progress "Loading seed data...", num_lines(UBIOTA) do |progress_bar|
  File.open(UBIOTA).each do |line|
    id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    next if rank == "rank"
    break if rank == "6"
    Taxon.create!(:id => id, :name => term, :rank => rank, :parent_id => parent_id)
    progress_bar.inc
  end
end



