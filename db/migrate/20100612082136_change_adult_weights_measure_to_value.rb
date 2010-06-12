class ChangeAdultWeightsMeasureToValue < ActiveRecord::Migration
  def self.up
    change_column :adult_weights, :measure, :decimal, :null => false
    rename_column :adult_weights, :measure, :value_in_grams
  end

  def self.down
    rename_column :adult_weights, :value_in_grams, :measure
    change_column :adult_weights, :measure, :string

  end
end