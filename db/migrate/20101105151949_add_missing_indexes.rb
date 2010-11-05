class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :adult_weights, :species_id
    add_index :adult_weights, :id, :unique => true
    add_index :birth_weights, :id, :unique => true
    add_index :lifespans, :species_id
    add_index :litter_sizes, :id, :unique => true
    add_index :litter_sizes, :species_id
    add_index :users, :email, :unique => true
    add_index :users, :id, :unique => true
  end

  def self.down
    remove_index :users, :column => :id
    remove_index :users, :column => :email
    remove_index :litter_sizes, :species_id
    remove_index :litter_sizes, :column => :id
    remove_index :lifespans, :species_id
    remove_index :birth_weights, :id
    remove_index :adult_weights, :id
    remove_index :adult_weights, :species_id
  end
end
