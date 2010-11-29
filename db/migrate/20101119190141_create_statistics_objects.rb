class CreateStatisticsObjects < ActiveRecord::Migration
  def self.up
    Taxon.rebuild_statistics_objects
  end
end
