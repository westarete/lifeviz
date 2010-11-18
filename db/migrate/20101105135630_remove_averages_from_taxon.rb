class RemoveAveragesFromTaxon < ActiveRecord::Migration
  def self.up
    remove_column :taxa, :avg_adult_weight
    remove_column :taxa, :avg_birth_weight
    remove_column :taxa, :avg_lifespan
    remove_column :taxa, :avg_litter_size
  end

  def self.down
    add_column :taxa, :avg_litter_size, :float
    add_column :taxa, :avg_lifespan, :float
    add_column :taxa, :avg_birth_weight, :float
    add_column :taxa, :avg_adult_weight, :float
  end
end
