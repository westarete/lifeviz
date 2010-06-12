class CreateLitterSizes < ActiveRecord::Migration
  def self.up
    create_table :litter_sizes do |t|
      t.integer :species_id , :null => false
      t.integer :measure    , :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :litter_sizes
  end
end
