class ChangeLifespanValueInDaysToNumericType < ActiveRecord::Migration
  def self.up
    change_column :lifespans, :value_in_days, :numeric, :precision => 8, :scale => 3
  end

  def self.down
    change_column :lifespans, :value_in_days, :integer
  end
end
