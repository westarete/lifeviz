class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.integer       :taxon_id
      t.string        :name
      t.string        :synonyms
      t.timestamps
    end
    add_index :species, :id
  end

  def self.down
    remove_index :species, :id
    drop_table :species
  end
end
