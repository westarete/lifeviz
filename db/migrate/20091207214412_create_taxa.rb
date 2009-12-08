class CreateTaxa < ActiveRecord::Migration
  def self.up
    create_table :taxa do |t|
      t.string :name
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :rank
      t.string :lineage_ids
    end
    add_index :taxa, :id
    add_index :taxa, :parent_id
  end

  def self.down
    remove_index :taxa, :parent_id
    remove_index :taxa, :id
    drop_table :nodes
  end
end
