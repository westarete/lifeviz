class TurnLitterSizeMeasureIntoValue < ActiveRecord::Migration
  def self.up
    rename_column :litter_sizes, :measure, :value
    change_column :litter_sizes, :value, :decimal
  end

  def self.down
    change_column :litter_sizes, :value, :integer
    rename_column :litter_sizes, :value, :measure
  end
end