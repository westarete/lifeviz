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

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20100707145800) do
=======
ActiveRecord::Schema.define(:version => 20100708184107) do
>>>>>>> master

  create_table "adult_weights", :force => true do |t|
    t.integer  "species_id",      :null => false
    t.decimal  "value_in_grams",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "units"
    t.integer  "created_by"
    t.string   "created_by_name"
  end

  create_table "birth_weights", :force => true do |t|
    t.integer  "species_id"
    t.decimal  "value_in_grams"
    t.string   "units"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.string   "created_by_name"
  end

  add_index "birth_weights", ["species_id"], :name => "index_birth_weights_on_species_id"

  create_table "lifespans", :force => true do |t|
    t.integer  "species_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "value_in_days"
    t.string   "units"
    t.integer  "created_by"
    t.string   "created_by_name"
  end

  add_index "lifespans", ["id"], :name => "index_species_on_id"

  create_table "litter_sizes", :force => true do |t|
    t.integer  "species_id",      :null => false
    t.integer  "measure",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.string   "created_by_name"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "taxa", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "rank"
    t.string  "lineage_ids"
    t.float   "avg_adult_weight"
    t.float   "avg_birth_weight"
    t.float   "avg_lifespan"
    t.float   "avg_litter_size"
  end

  add_index "taxa", ["id"], :name => "index_taxa_on_id"
  add_index "taxa", ["lft"], :name => "index_taxa_on_lft"
  add_index "taxa", ["name"], :name => "index_taxa_on_name"
  add_index "taxa", ["parent_id"], :name => "index_taxa_on_parent_id"
  add_index "taxa", ["rank"], :name => "index_taxa_on_rank"
  add_index "taxa", ["rgt"], :name => "index_taxa_on_rgt"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openid_identifier"
    t.string   "name"
  end

  add_index "users", ["openid_identifier"], :name => "index_users_on_openid_identifier"

end
