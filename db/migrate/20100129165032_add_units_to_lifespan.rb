class AddUnitsToLifespan < ActiveRecord::Migration
  def self.up
    add_column :lifespans, :units, :string
  end

  def self.down
    remove_column :lifespans, :units
  end
end
