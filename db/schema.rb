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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111220142149) do

  create_table "attachments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "status"
    t.string   "copyright"
    t.string   "note"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "commentable_website_id"
    t.text     "body"
    t.integer  "count_vote_1"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.string   "session_id"
    t.string   "auth_token"
    t.string   "temporary_email"
    t.text     "ip"
    t.text     "agent"
    t.boolean  "remember_me"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "website_id"
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.text     "recipient_list"
    t.string   "to_type"
    t.text     "body"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "website_id"
    t.integer  "user_id"
    t.integer  "post_id"
    t.text     "title"
    t.text     "description"
    t.text     "comma_separated_tags"
    t.string   "address_by_user"
    t.text     "map_data"
    t.string   "map_address"
    t.integer  "map_lat"
    t.integer  "map_lng"
    t.string   "map_bounds"
    t.integer  "map_zoom"
    t.string   "editing_comment"
    t.integer  "count_children"
    t.integer  "count_views"
    t.integer  "count_vote_1"
    t.integer  "count_vote_2"
    t.integer  "count_vote_3"
    t.integer  "count_vote_4"
    t.string   "status"
    t.string   "progress"
    t.string   "errors_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
    t.integer "taggable_website_id"
    t.boolean "taggable_visible"
    t.boolean "taggable_is_a_father"
    t.boolean "tag_visible"
    t.integer "tag_child_of_tag_id"
  end

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.string  "clean_name"
    t.integer "child_of_tag_id"
    t.integer "translation_of_tag_id"
    t.string  "main_translation"
    t.string  "status"
    t.integer "level"
    t.string  "bounds"
    t.string  "language"
    t.string  "wikipedia_name"
  end

  add_index "tags", ["child_of_tag_id"], :name => "index_tags_on_child_of_tag_id"
  add_index "tags", ["translation_of_tag_id"], :name => "index_tags_on_translation_of_tag_id"

  create_table "users", :force => true do |t|
    t.string   "encrypted_email"
    t.string   "temporary_email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "locale"
    t.string   "subtype"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "email_confirmation_token"
    t.boolean  "email_confirmed"
    t.string   "messages_token"
    t.string   "first"
    t.string   "middle"
    t.string   "last"
    t.string   "status"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "votable_website_id"
    t.boolean  "votable_visible"
    t.boolean  "user_visible"
    t.integer  "vote_1"
    t.integer  "vote_2"
    t.integer  "vote_3"
    t.integer  "vote_4"
    t.integer  "edited"
    t.integer  "commented"
    t.integer  "owner"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
