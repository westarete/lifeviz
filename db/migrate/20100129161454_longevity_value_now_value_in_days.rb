class LongevityValueNowValueInDays < ActiveRecord::Migration
  def self.up
    rename_column :lifespans, :value, :value_in_days
    change_column :lifespans, :value_in_days, :integer
  end

  def self.down
    change_column :lifespans, :value_in_days, :float
    rename_column :lifespans, :value_in_days, :value
  end
end
