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

ActiveRecord::Schema.define(version: 20150915011113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "playlist_id"
    t.integer  "track_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["playlist_id"], name: "index_likes_on_playlist_id", using: :btree
  add_index "likes", ["track_id"], name: "index_likes_on_track_id", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "listeners", force: true do |t|
    t.integer  "playlist_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "listeners", ["playlist_id"], name: "index_listeners_on_playlist_id", using: :btree
  add_index "listeners", ["user_id"], name: "index_listeners_on_user_id", using: :btree

  create_table "playlists", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "playlists", ["user_id"], name: "index_playlists_on_user_id", using: :btree

  create_table "tracks", force: true do |t|
    t.integer  "playlist_id"
    t.string   "title"
    t.string   "artist"
    t.string   "album"
    t.integer  "duration"
    t.string   "playable_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["playlist_id"], name: "index_tracks_on_playlist_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
