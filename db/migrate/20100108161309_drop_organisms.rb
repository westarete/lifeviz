class DropOrganisms < ActiveRecord::Migration
  def self.up
    drop_table :organisms
  end

  def self.down
    create_table "organisms", :force => true do |t|
      t.integer  "taxon_id"
      t.string   "name"
      t.string   "synonyms"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
