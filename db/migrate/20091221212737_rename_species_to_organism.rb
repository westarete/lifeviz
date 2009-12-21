class RenameSpeciesToOrganism < ActiveRecord::Migration
  def self.up
    rename_table :species, :organisms
  end

  def self.down
    rename_table :organisms, :species
  end
end
