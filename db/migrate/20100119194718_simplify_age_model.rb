class SimplifyAgeModel < ActiveRecord::Migration
  def self.up
    remove_column :ages, :synonyms
    remove_column :ages, :initial_mortality_rate
    remove_column :ages, :mortality_rate_doubling_time
    rename_column :ages, :taxon_id, :species_id
  end

  def self.down
    rename_column :ages, :species_id, :taxon_id
    add_column :ages, :mortality_rate_doubling_time, :float
    add_column :ages, :initial_mortality_rate, :float
    add_column :ages, :synonyms, :string
  end
end
