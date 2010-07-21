class TaxaAnalytics < ActiveRecord::Migration
  def self.up
    add_column :taxa, :avg_adult_weight ,:float
    add_column :taxa, :avg_birth_weight ,:float
    add_column :taxa, :avg_lifespan     ,:float
    add_column :taxa, :avg_litter_size  ,:float
  end

  def self.down
    remove_column :taxa, :avg_litter_size
    remove_column :taxa, :avg_lifespan
    remove_column :taxa, :avg_birth_weight
    remove_column :taxa, :avg_adult_weight
  end
end