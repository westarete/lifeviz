# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100106160708) do

  create_table "organisms", :force => true do |t|
    t.integer  "taxon_id"
    t.string   "name"
    t.string   "synonyms"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisms", ["id"], :name => "index_species_on_id"

  create_table "taxa", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "rank"
    t.string  "lineage_ids"
  end

  add_index "taxa", ["lft"], :name => "index_taxa_on_lft"
  add_index "taxa", ["parent_id"], :name => "index_taxa_on_parent_id"
  add_index "taxa", ["rank"], :name => "index_taxa_on_rank"
  add_index "taxa", ["rgt"], :name => "index_taxa_on_rgt"

  create_table "users", :force => true do |t|
    t.string   "email",             :null => false
    t.string   "crypted_password",  :null => false
    t.string   "password_salt",     :null => false
    t.string   "persistence_token", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
