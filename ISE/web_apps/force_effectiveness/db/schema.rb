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

ActiveRecord::Schema.define(:version => 20100712175744) do

  create_table "fe_areas", :force => true do |t|
    t.integer  "fe_run_id"
    t.string   "label"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fe_engagements", :force => true do |t|
    t.integer  "fe_run_id"
    t.integer  "fe_launcher_id"
    t.integer  "fe_threat_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fe_interceptors", :force => true do |t|
    t.integer  "fe_run_id"
    t.string   "label"
    t.string   "category"
    t.integer  "fe_engagement_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fe_launchers", :force => true do |t|
    t.integer  "fe_run_id"
    t.string   "label"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fe_runs", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "mp_scenario_id"
    t.integer  "mp_tewa_configuration_id"
    t.integer  "first_frame"
    t.integer  "last_frame"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mps_idp_name",             :default => ""
    t.string   "mps_sg_name",              :default => ""
    t.string   "mptc_name",                :default => ""
  end

  create_table "fe_threats", :force => true do |t|
    t.integer  "fe_run_id"
    t.string   "label"
    t.string   "category"
    t.integer  "target_area_id"
    t.integer  "source_area_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
