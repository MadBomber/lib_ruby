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

ActiveRecord::Schema.define(:version => 20101129150303) do

  create_table "mp_batteries", :force => true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_battery_configurations", :force => true do |t|
    t.integer  "mp_battery_id",                  :null => false
    t.integer  "mp_launcher_id",                 :null => false
    t.integer  "mp_launcher_qty", :default => 8, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_interceptors", :force => true do |t|
    t.string   "name",                                   :null => false
    t.string   "desc"
    t.integer  "pk_air",               :default => 100,  :null => false
    t.integer  "pk_space",             :default => 100,  :null => false
    t.integer  "velocity",             :default => 5000, :null => false
    t.integer  "cost",                 :default => 0,    :null => false
    t.integer  "eng_zone_scale_air",   :default => 1,    :null => false
    t.integer  "eng_zone_scale_space", :default => 1,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_range_meters",     :default => 5000
  end

  create_table "mp_launcher_doctrines", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_launchers", :force => true do |t|
    t.string   "name",                              :null => false
    t.string   "desc"
    t.integer  "mp_interceptor_id",                 :null => false
    t.integer  "mp_interceptor_qty", :default => 4, :null => false
    t.integer  "abt_doctrine_id",                   :null => false
    t.integer  "tbm_doctrine_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_scenarios", :force => true do |t|
    t.string   "name",                                   :null => false
    t.string   "desc"
    t.string   "idp_name",                               :null => false
    t.string   "sg_name",                                :null => false
    t.datetime "executed_at"
    t.string   "ise_guid"
    t.boolean  "selected",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "random_threat_count", :default => 0
    t.boolean  "auto_engage_tbm",     :default => false
    t.boolean  "auto_engage_abt",     :default => false
    t.boolean  "man_in_the_loop",     :default => true
  end

  create_table "mp_tewa_configurations", :force => true do |t|
    t.string   "name",                          :null => false
    t.string   "desc"
    t.boolean  "doctrine",   :default => true,  :null => false
    t.boolean  "selected",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_tewa_factors", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "desc"
    t.string   "category",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_tewa_values", :force => true do |t|
    t.integer  "mp_tewa_factor_id",                       :null => false
    t.integer  "mp_tewa_configuration_id",                :null => false
    t.integer  "value",                    :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_threats", :force => true do |t|
    t.string   "name",                                :null => false
    t.string   "desc"
    t.string   "track_category", :default => "space", :null => false
    t.float    "effects_radius", :default => 1.0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
