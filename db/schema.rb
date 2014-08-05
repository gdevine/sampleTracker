# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140805052536) do

  create_table "containers", force: true do |t|
    t.string   "container_type"
    t.text     "description"
    t.integer  "storage_location_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "containers", ["owner_id", "created_at"], name: "index_containers_on_owner_id_and_created_at"

  create_table "facilities", force: true do |t|
    t.string   "code"
    t.string   "description"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facilities", ["code"], name: "index_facilities_on_code"

  create_table "sample_sets", force: true do |t|
    t.integer  "owner_id"
    t.date     "sampling_date"
    t.integer  "facility_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "add_info"
    t.integer  "num_samples"
  end

  add_index "sample_sets", ["owner_id", "created_at"], name: "index_sample_sets_on_owner_id_and_created_at"

  create_table "samples", force: true do |t|
    t.integer  "sample_set_id"
    t.integer  "owner_id"
    t.boolean  "sampled"
    t.date     "date_sampled"
    t.integer  "facility_id"
    t.integer  "project_id"
    t.text     "comments"
    t.boolean  "is_primary"
    t.integer  "ring"
    t.integer  "tree"
    t.integer  "plot"
    t.float    "northing"
    t.float    "easting"
    t.float    "vertical"
    t.string   "material_type"
    t.string   "amount_collected"
    t.string   "amount_stored"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "storage_location_id"
    t.integer  "parent_id"
    t.integer  "container_id"
  end

  add_index "samples", ["owner_id", "created_at"], name: "index_samples_on_owner_id_and_created_at"

  create_table "storage_locations", force: true do |t|
    t.string   "code"
    t.string   "building"
    t.integer  "room"
    t.text     "description"
    t.integer  "custodian_id"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "firstname"
    t.string   "surname"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.boolean  "admin"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
