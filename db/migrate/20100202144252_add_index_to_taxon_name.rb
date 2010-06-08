class AddIndexToTaxonName < ActiveRecord::Migration
  def self.up
    add_index :taxa, :name
  end

  def self.down
    remove_index :taxa, :name
  end
end
