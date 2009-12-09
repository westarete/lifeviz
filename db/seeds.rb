require 'progressbar'
require 'db/seed_methods'
require 'nokogiri'
require 'debugger'
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

# # Load new taxonomy information from UBioTa.
# progress "Loading seed data...", num_lines(UBIOTA) do |progress_bar|
#   File.open(UBIOTA).each do |line|
#     id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
#     next if rank == "rank"
#     break if rank == "6"
#     taxon = Taxon.new
#     taxon.id = id.to_i
#     taxon.name = term
#     taxon.rank = rank.to_i
#     if parent_id == "-1"
#       taxon.parent_id = nil
#     else
#       taxon.parent_id = parent_id.to_i
#     end
#     taxon.send(:create_without_callbacks)
#     progress_bar.inc
#   end
# end

# Load species data from AnAge.
puts "Loading AnAge data..."
anage = Nokogiri::XML.parse(File.open(ANAGE))
debugger
num_lines = "heyo"




