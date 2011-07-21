ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'progressbar'
require 'db/seed_methods'
require 'fastercsv'
include SeedMethods

LIFESPANS  = "db/data/lifespans.csv.bz2"

ANAGE_USER = User.find_by_name("Anage")
ANAGE_USER_ID = ANAGE_USER.id
ANAGE_USER_NAME = ANAGE_USER.name

def import_lifespan_data
  lifespans = nil
  seed "Opening lifespan data" do
    lifespans = IO.popen("bunzip2 -c #{LIFESPANS}")
    lifespans ? true : false
  end
  
  anage_lifespans = []
  seed "Deleting old lifespans" do
    anage_lifespans = Lifespan.find(:all, :conditions => {:created_by_name => "Anage"})
    anage_lifespans.each do |lifespan|
      lifespan.destroy
    end
    true
  end
  notice success_string("There were #{anage_lifespans.count} anage lifespans deleted.")
  
  seed "Saving lifespans from Cera's modifications"
  number_of_lines = num_lines_bz2(LIFESPANS)
  failures = 0
  successes = 0
  progress "Lifespan", number_of_lines do |progress_bar|
    lifespans.each_with_index do |line, i|
      _, species_id, _, _, value_in_days, units, _, _, citation, context, reliable = FasterCSV.parse(line)[0]
      lifespan = Lifespan.new
      lifespan.species_id = species_id.to_i
      lifespan.value_in_days = value_in_days.to_i
      lifespan.units = units
      lifespan.citation = citation
      lifespan.context = context
      lifespan.created_by = ANAGE_USER
      lifespan.save ? successes += 1 : failures += 1
      progress_bar.inc
    end
  end
  
  notice success_string("Saved #{successes} new lifespans successfully.")
  notice failure_string("Saved #{failures} lifespans successfully.")
end

import_lifespan_data
