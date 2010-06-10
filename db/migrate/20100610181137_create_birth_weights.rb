class CreateBirthWeights < ActiveRecord::Migration
  def self.up
    create_table :birth_weights do |t|
      t.integer     :species_id
      t.decimal     :value_in_grams
      t.string      :units
      t.timestamps
    end
    add_index :birth_weights, :species_id
  end

  def self.down
    remove_index :birth_weights, :species_id
    drop_table :birth_weights
  end
end
