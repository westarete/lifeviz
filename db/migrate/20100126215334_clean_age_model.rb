class CleanAgeModel < ActiveRecord::Migration
  def self.up
    rename_table :ages, :lifespans
    remove_column :lifespans, :phenotype
    rename_column :lifespans, :maximum_longevity, :value
  end

  def self.down
    rename_column :lifespans, :value, :maximum_longevity
    add_column :lifespans, :phenotype, :string
    rename_table :lifespans, :ages
  end
end
