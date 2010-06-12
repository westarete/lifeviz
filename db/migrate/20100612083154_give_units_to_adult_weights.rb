class GiveUnitsToAdultWeights < ActiveRecord::Migration
  def self.up
    add_column :adult_weights, :units, :string
  end

  def self.down
    remove_column :adult_weights, :units
  end
end