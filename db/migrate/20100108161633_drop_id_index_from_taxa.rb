class DropIdIndexFromTaxa < ActiveRecord::Migration
  def self.up
    remove_index :taxa, :name => :index_taxa_on_id
  end

  def self.down
    add_index :taxa, :id
  end
end
