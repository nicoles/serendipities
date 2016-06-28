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

ActiveRecord::Schema.define(version: 20160628201313) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "oauth_credentials", force: true do |t|
    t.string   "type",          limit: nil
    t.string   "uid",           limit: nil
    t.integer  "user_id"
    t.string   "token",         limit: nil
    t.string   "refresh_token", limit: nil
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", force: true do |t|
    t.integer  "moves_id"
    t.string   "name"
    t.string   "source"
    t.string   "source_guid"
    t.decimal  "latitude",    precision: 10, scale: 6, null: false
    t.decimal  "longitude",   precision: 10, scale: 6, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", force: true do |t|
    t.datetime "start_time",   null: false
    t.datetime "end_time"
    t.integer  "storyline_id", null: false
    t.integer  "segment_id"
    t.string   "segment_type"
    t.boolean  "move",         null: false
    t.integer  "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "segments", ["segment_id", "segment_type"], name: "index_segments_on_segment_id_and_segment_type", using: :btree

  create_table "storylines", force: true do |t|
    t.integer  "user_id"
    t.date     "story_date"
    t.json     "moves_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
  end

end
