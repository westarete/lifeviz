class AddCitationsToAnnotations < ActiveRecord::Migration
  def self.up
    [:adult_weights, :birth_weights, :lifespans, :litter_sizes].each do |table|
      add_column table, :citation, :text
      add_column table, :context, :text
    end
    drop_table :citations
  end

  def self.down
    create_table "citations", :force => true do |t|
      t.integer  "reference_id", :null => false
      t.integer  "taxon_id",     :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    [:adult_weights, :birth_weights, :lifespans, :litter_sizes].each do |table|
      remove_column table, :citation
      remove_column table, :context
    end
  end
end
