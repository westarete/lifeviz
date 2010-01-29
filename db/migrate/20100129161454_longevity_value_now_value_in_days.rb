class LongevityValueNowValueInDays < ActiveRecord::Migration
  def self.up
    change_column :value, :value_in_days, :integer    
  end

  def self.down
    change_column :value, :value_in_days, :float
  end
end
