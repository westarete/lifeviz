class TurnOrganismIntoAge < ActiveRecord::Migration
  def self.up
    remove_column :organisms, :name
    rename_table :organisms, :ages
    add_column :ages, :initial_mortality_rate, :float
    add_column :ages, :mortality_rate_doubling_time, :float
    add_column :ages, :maximum_longevity, :float
    add_column :ages, :phenotype, :string
  end

  def self.down
    remove_column :ages, :phenotype
    remove_column :ages, :maximum_longevity
    remove_column :ages, :mortality_rate_doubling_time
    remove_column :ages, :initial_mortality_rate
    rename_table :ages, :organisms
    add_column :organisms, :names, :string
  end
end
