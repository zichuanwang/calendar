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

ActiveRecord::Schema.define(version: 20150210082933) do

  create_table "cals", force: :cascade do |t|
    t.string   "calendar_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "sync_token"
    t.string   "foreground_color"
    t.string   "background_color"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "cals", ["calendar_id"], name: "index_cals_on_calendar_id"
  add_index "cals", ["user_id"], name: "index_cals_on_user_id"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.string   "event_id"
    t.text     "description"
    t.integer  "cal_id"
    t.integer  "user_id"
    t.string   "url"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "events", ["cal_id"], name: "index_events_on_cal_id"
  add_index "events", ["event_id"], name: "index_events_on_event_id"
  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "refresh_token"
    t.string   "access_token"
    t.string   "calendar_list_sync_token"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
