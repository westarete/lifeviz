require 'progressbar'
require 'db/seed_methods'
require 'nokogiri'
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

# Remove any existing taxa
puts "Removing any existing taxa"
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

# Load species data from AnAge.
# puts "Loading AnAge data..."
# anage = Nokogiri::XML.parse(File.open(ANAGE))
# debugger
# num_lines = "heyo"




