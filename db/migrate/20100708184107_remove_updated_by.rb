class RemoveUpdatedBy < ActiveRecord::Migration
  def self.up
    remove_column :litter_sizes, :updated_by_name
    remove_column :litter_sizes, :updated_by
    remove_column :lifespans, :updated_by_name
    remove_column :lifespans, :updated_by
    remove_column :birth_weights, :updated_by_name
    remove_column :birth_weights, :updated_by
    remove_column :adult_weights, :updated_by_name
    remove_column :adult_weights, :updated_by
  end

  def self.down
    add_column :adult_weights, :updated_by, :integer
    add_column :adult_weights, :updated_by_name, :string
    add_column :birth_weights, :updated_by, :integer
    add_column :birth_weights, :updated_by_name, :string
    add_column :lifespans, :updated_by, :integer
    add_column :lifespans, :updated_by_name, :string
    add_column :litter_sizes, :updated_by, :integer
    add_column :litter_sizes, :updated_by_name, :string
  end
end
