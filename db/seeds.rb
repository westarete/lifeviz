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
  num_lines = 0
  puts "Calculating total size of job"
  IO.popen("bunzip2 -c #{filename}").each do |line|
    id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")
    next if rank  == "rank"
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

  # the data we import contains ids and expects we start at 1
  puts "Setting taxon id sequence back to 1"
  ActiveRecord::Base.connection.execute "SELECT setval('taxa_id_seq',1);"

  # Load new taxonomy information from UBioTa.
  progress "Loading seed data...", num_taxa_lines_bz2(UBIOTA) do |progress_bar|
    IO.popen("bunzip2 -c #{UBIOTA}").each do |line|
      id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")

      # skip the header
      next if rank == "rank"

      # we aren't working with species at this point
      break if rank == "6"

      taxon           = Taxon.new
      taxon['id']     = id.to_i
      taxon.name      = term
      taxon.rank      = rank.to_i
      taxon.parent_id = parent_id == "-1" ? nil : parent_id.to_i

      taxon.send(:create_without_callbacks)

      progress_bar.inc
    end
  end

  # psql sequence doesn't increment if you set ids by hand. we need to have it
  # pickup where our last taxon id left off.
  last_taxon_id = ActiveRecord::Base.connection.execute "SELECT MAX(ID) FROM taxa;"
  next_taxon_id = last_taxon_id.max["max"].to_i + 1
  ActiveRecord::Base.connection.execute "SELECT setval('taxa_id_seq', #{next_taxon_id});"
end

# TODO: remove this method if the data will include the lineage ids
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

# Create species from lifeviz/ubiota using hagrid_ubid as the bridge
# Collect species data from Lifeviz
# Collect taxonomy species name and hierarchy from ubiota
def create_species_and_data
  new_species       = []
  orphaned_species  = []

  # Entrance message
  puts "** Creating new species from lifeviz/ubiota files using hagrid_ubid as the bridge"
  puts " NOTE: new species are species with data imported from lifeviz, orphaned species are "
  puts "       ubiota species with no associated lifeviz data"

  # Open files
  puts "** Opening data files..."
  lifeviz = IO.popen("bunzip2 -c #{LIFEVIZ}")
  ubiota  = IO.popen("bunzip2 -c #{UBIOTA}")
  map     = IO.readlines(LIFEVIZ_UBIOTA)
  lifeviz && ubiota && map ? (puts "success") : (puts "*failed"; exit!)

  # Dump all related data
  puts "** Removing any existing age, litter sizes, adult weights,birth weights data..."
  Lifespan.delete_all && LitterSize.delete_all && AdultWeight.delete_all && BirthWeight.delete_all ? (puts "success") : (puts "failed"; exit!)

  # Load taxon from lifeviz using hpricot
  puts "** Loading lifeviz data..."
  doc                 = Hpricot::XML(lifeviz)
  lifeviz_names       = (doc/'names')
  lifeviz_ages        = (doc/'age')
  lifeviz_development = (doc/'development')

  puts  "success: #{lifeviz_names.size} names, #{lifeviz_ages.size} ages, #{lifeviz_development.size} development records loaded"

  # Collect lifeviz data so it's manageble and easy to create into new species
  puts "** Staging new species..."

  pointer = 0
  progress "Staging", lifeviz_names.length do |progress_bar|
    lifeviz_names.each_with_index do |s, index|
      hagrid        = (s/'id_hagr').inner_html
      x = {}
      x[:synonyms] = (s/'name_common').inner_html
      x[:age]      = (lifeviz_ages[index]/'tmax').inner_html
      x[:hagrid]   = hagrid

      if lifeviz_development[pointer]

        # the development records are a bit tricky. there isn't always a record
        # for each species so we need to use a separate index and will need to
        # have the dev record id falling behind catchup to the current record id (hagrid)
        # NOTE: this iterates until the condition is met
        while (lifeviz_development[pointer]/'hagrid').inner_html.to_i < hagrid.to_i
          pointer += 1
        end

        # development attributes matches the current species id
        if (lifeviz_development[pointer]/'hagrid').inner_html.to_i == hagrid.to_i
          development       = lifeviz_development[pointer]
          x[:adult_weight]  = (development/'adult_weight').inner_html.to_f
          x[:birth_weight]  = (development/'birth_weight').inner_html.to_f
          x[:litter_size]   = (development/'litter_size').inner_html.to_f
          pointer += 1
        end

      end

      # store into the array so be created later
      new_species << x

      progress_bar.inc
    end
  end

  puts "success: #{new_species.size} species staged"

  # Load ubid ids into new species from mapping
  puts "** Assigning mapped ubiota ids species..."
  pointer = 0

  # handle the mapping of (hagrid to ubid) line by line
  map.each do |line|

    # lifeviz id that is mapped to ubiota id
    hagrid, ubid = line.split(/\s+/)

    # there are species that aren't in the map so we'll want to skip them
    pointer += 1 until new_species[pointer][:hagrid] == hagrid

    # this species matches the mapped hagrid so assign it's mapped ubid
    new_species[pointer][:ubid] = ubid.to_i
  end
  puts "success"

  # Remove any new species that didn't exist in the mapping and were skipped
  count = new_species.size
  puts "** Deleting any species that are not mapped to ubiota ids..."
  new_species.delete_if { |species| species[:ubid] == nil }
  puts "success: deleted #{count - new_species.size} species, #{new_species.size} remaining"

  # Sort species by ubid so it will be easier to work with and will be much
  # faster to increment
  puts "** Sorting species by ubiota ids..."
  new_species = new_species.sort_by { |each| each[:ubid] }
  puts "success"

  # Find and load ubiota genus ids and species name for each species
  #   Ensure the rank is 6 (species level)
  #   Set taxon_id to nil if the species inside ubiota doesn't exist
  puts "** Loading ubiota data for each species..."
  pointer = 0
  a_couple = 0
  progress "Loading...", num_lines_bz2(UBIOTA) do |progress_bar|
    ubiota.each do |line|
      ubiota_id, term, rank, hierarchy, parent_id, num_children, hierarchy_ids = line.split("|")

      # skip if we're not looking at a species level taxon
      if rank.to_i != 6
        progress_bar.inc
        next
      end

      # TODO: this can be rewritten to be clearer
      # store a ubiota species as an orphan if
      if new_species[pointer].nil? || new_species[pointer][:ubid] != ubiota_id.to_i
        y = {:taxon_id => parent_id.to_i, :name => term.to_s}
        orphaned_species << y
        if ! new_species[pointer].nil? then new_species[pointer][:taxon_id] = nil end
        if ! new_species[pointer].nil? && ubiota_id.to_i > new_species[pointer][:ubid] then pointer += 1 end
      else
        new_species[pointer][:taxon_id] = parent_id.to_i
        new_species[pointer][:name]     = term.to_s
        pointer += 1
      end

     # # Proposed rewrite for above TODO. be sure to double check.
     # # Store ubiota data for matched species. there are many species in
     # # ubiota data that aren't staged (orphans) that should be added to the
     # # staged species (called orphans) and also staged species that aren't
     # # in ubiota that need to be skipped
     # if new_species[pointer] && new_species[pointer][:ubid] == ubiota_id.to_i
     #   new_species[pointer][:taxon_id] = parent_id.to_i
     #   new_species[pointer][:name]     = term.to_s
     #   pointer += 1
     # else
     #   if new_species[pointer]
     #     new_species[pointer][:taxon_id] = nil
     #     pointer += 1 while ubiota_id.to_i > new_species[pointer][:ubid]
     #   end
     #   orphan = {:taxon_id => parent_id.to_i, :name => term.to_s}
     #   orphaned_species << orphan
     # end

      progress_bar.inc
    end
  end
  puts "success: traversed #{pointer} staged species and added #{orphaned_species.size} species to be staged"

  # Remove any new species that has no genus in ubiota
  count = new_species.size
  puts "** Delete any species that had no genus id... "
  new_species.delete_if { |species| species[:taxon_id] == nil }
  puts "success: deleted #{count - new_species.size} species, #{new_species.size} remaining"

  # Remove any orphaned species that has no genus in ubiota
  count = orphaned_species.size
  puts "** Delete any newly staged species that had no genus id... "
  orphaned_species.delete_if { |species| species[:taxon_id] == 0 }
  puts "success: deleted #{count - orphaned_species.size} species, #{orphaned_species.size} remaining"

  # Create all staged species
  count   = 0
  fcount  = 0
  age_nil = 0
  birth_weight_nil = 0
  adult_weight_nil = 0
  litter_size_nil  = 0

  puts "** Saving staged species..."
  start_time = Time.now
  progress "Species", new_species.length do |progress_bar|
    new_species.each_with_index do |s, index|
      taxon   = Taxon.find_by_id(s[:taxon_id])
      if taxon

        species = Taxon.find_by_name(s[:name])
        if species.nil?
          species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
          species.send(:create_without_callbacks)
        end

        # only create these if the data was previously set
        age          = Lifespan.new(:value_in_days => (s[:age].to_f * 365), :units => "Years", :species_id => species.id)   if ! s[:age].blank?
        birth_weight = BirthWeight.new(:value_in_grams => (s[:birth_weight]), :units => "Grams", :species_id => species.id) if ! s[:birth_weight].blank?
        adult_weight = AdultWeight.new(:value_in_grams => (s[:adult_weight]), :units => "Grams", :species_id => species.id) if ! s[:adult_weight].blank?
        litter_size  = LitterSize.new(:measure => (s[:litter_size]), :species_id => species.id)                             if ! s[:litter_size].blank?
        age.nil?          ? (age_nil += 1)          : age.send(:create_without_callbacks)
        adult_weight.nil? ? (adult_weight_nil += 1) : adult_weight.send(:create_without_callbacks)
        birth_weight.nil? ? (birth_weight_nil += 1) : birth_weight.send(:create_without_callbacks)
        litter_size.nil?  ? (litter_size_nil += 1)  : litter_size.send(:create_without_callbacks)

      else
        fcount += 1
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

  # Create orphaned species
  count   = 0
  fcount  = 0
  puts "** Saving all the orphaned species..."
  progress "Orphans", orphaned_species.length do |progress_bar|
    orphaned_species.each_with_index do |s, index|
      taxon   = Taxon.find_by_id(s[:taxon_id])
      if taxon
        species = Taxon.new(:name => s[:name], :parent_id => taxon.id, :rank => 6)
        # species.send(:create_without_callbacks)
      else
       puts "fail: no taxon found with and id of #{s[:taxon_id].to_s} for species with ubid of #{s[:ubid].to_s}"
       fcount += 1
      end

      count = index

      progress_bar.inc
    end
  end
  puts "success: Phew!... saved #{count - fcount} species"
  puts "failure: #{fcount} species didn't have taxons matching taxon_id in our database" if fcount != 0

  # Exit message
  puts "Species creation is completed"

  puts "** Running Taxon.rebuild! "
  Taxon.rebuild!
  puts "success\n\n"
  puts "NOTE: don't forget to run vacuum analyze\n"
end

# Execute taxonomy creation method
create_taxonomy
# Execute species creation method
create_species_and_data
rebuild_lineages
