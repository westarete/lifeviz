class TaxaStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics, :force => true do |t|
      t.integer :taxon_id
      t.float :minimum_lifespan
      t.float :minimum_adult_weight
      t.float :minimum_litter_size
      t.float :minimum_birth_weight
      t.float :maximum_lifespan
      t.float :maximum_adult_weight
      t.float :maximum_litter_size
      t.float :maximum_birth_weight
      t.float :average_lifespan
      t.float :average_adult_weight
      t.float :average_litter_size
      t.float :average_birth_weight
      t.float :standard_deviation_lifespan
      t.float :standard_deviation_adult_weight
      t.float :standard_deviation_litter_size
      t.float :standard_deviation_birth_weight
      t.timestamps
    end
  end    

  def self.down
    drop_table :statistics
  end
end
