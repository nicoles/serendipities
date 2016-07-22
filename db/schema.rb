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

ActiveRecord::Schema.define(version: 20160629155236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "segment_id",     null: false
    t.string   "activity_type",  null: false
    t.string   "activity_group"
    t.integer  "duration"
    t.integer  "distance"
    t.integer  "calories"
    t.integer  "steps"
    t.boolean  "manual"
    t.json     "track_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_credentials", force: true do |t|
    t.string   "type"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", force: true do |t|
    t.integer  "moves_id"
    t.string   "name"
    t.string   "place_type"
    t.string   "facebook_place_id"
    t.string   "foursquare_id"
    t.string   "foursquare_category_ids",                                       array: true
    t.decimal  "latitude",                precision: 10, scale: 6, null: false
    t.decimal  "longitude",               precision: 10, scale: 6, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["foursquare_category_ids"], name: "index_places_on_foursquare_category_ids", using: :gin

  create_table "segments", force: true do |t|
    t.datetime "start_time",   null: false
    t.datetime "end_time",     null: false
    t.datetime "last_update"
    t.integer  "storyline_id", null: false
    t.string   "segment_type", null: false
    t.integer  "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "storylines", force: true do |t|
    t.integer  "user_id"
    t.date     "story_date"
    t.json     "moves_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_update"
    t.integer  "calories_idle"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
  end

end
