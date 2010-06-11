class CreateAdultWeights < ActiveRecord::Migration
  def self.up
    create_table :adult_weights do |t|
      t.integer :species_id, :null => false
      t.float :measure, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :adult_weights
  end
end