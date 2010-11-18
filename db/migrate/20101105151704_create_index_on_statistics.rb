class CreateIndexOnStatistics < ActiveRecord::Migration
  def self.up
    add_index :statistics, :id, :unique => true
    add_index :statistics, :taxon_id, :unique => true
  end

  def self.down
    remove_index :statistics, :column => :taxon_id
    remove_index :statistics, :column => :id
  end
end
