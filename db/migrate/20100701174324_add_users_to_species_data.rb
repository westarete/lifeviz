class AddUsersToSpeciesData < ActiveRecord::Migration
  def self.up
    add_column :adult_weights, :created_by, :integer
    add_column :adult_weights, :created_by_name, :string
    add_column :birth_weights, :created_by, :integer
    add_column :birth_weights, :created_by_name, :string
    add_column :lifespans, :created_by, :integer
    add_column :lifespans, :created_by_name, :string
    add_column :litter_sizes, :created_by, :integer
    add_column :litter_sizes, :created_by_name, :string
    add_column :adult_weights, :updated_by, :integer
    add_column :adult_weights, :updated_by_name, :string
    add_column :birth_weights, :updated_by, :integer
    add_column :birth_weights, :updated_by_name, :string
    add_column :lifespans, :updated_by, :integer
    add_column :lifespans, :updated_by_name, :string
    add_column :litter_sizes, :updated_by, :integer
    add_column :litter_sizes, :updated_by_name, :string
  end

  def self.down
    remove_column :litter_sizes, :updated_by_name
    remove_column :litter_sizes, :updated_by
    remove_column :lifespans, :updated_by_name
    remove_column :lifespans, :updated_by
    remove_column :birth_weights, :updated_by_name
    remove_column :birth_weights, :updated_by
    remove_column :adult_weights, :updated_by_name
    remove_column :adult_weights, :updated_by
    remove_column :litter_sizes, :created_by_name
    remove_column :litter_sizes, :created_by
    remove_column :lifespans, :created_by_name
    remove_column :lifespans, :created_by
    remove_column :birth_weights, :created_by_name
    remove_column :birth_weights, :created_by
    remove_column :adult_weights, :created_by_name
    remove_column :adult_weights, :created_by
  end
end
