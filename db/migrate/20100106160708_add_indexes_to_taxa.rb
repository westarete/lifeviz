class AddIndexesToTaxa < ActiveRecord::Migration
  def self.up
    add_index :taxa, :lft
    add_index :taxa, :rgt
    add_index :taxa, :rank
  end

  def self.down
    remove_index :taxa, :rank
    remove_index :taxa, :rgt
    remove_index :taxa, :lft
  end
end
