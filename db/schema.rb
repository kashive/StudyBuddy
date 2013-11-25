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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131123045956) do

  create_table "activities", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.string   "term"
    t.string   "professor"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "user_id"
    t.string   "department"
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "course_name"
  end

  create_table "fridays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "marketings", :force => true do |t|
    t.string   "inviting_user_id"
    t.boolean  "status"
    t.integer  "times_contacted"
    t.string   "email"
    t.string   "course_id"
    t.string   "study_session_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "mondays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "saturdays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "schedules", :force => true do |t|
    t.string   "user_id"
    t.string   "monday"
    t.string   "tuesday"
    t.string   "wednesday"
    t.string   "thursday"
    t.string   "friday"
    t.string   "saturday"
    t.string   "sunday"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "study_sessions", :force => true do |t|
    t.text     "title"
    t.string   "category"
    t.time     "time"
    t.date     "date"
    t.string   "location"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sundays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "thursdays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tuesdays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "college"
    t.string   "major_minors"
    t.string   "exp_graduation_date"
    t.string   "gender"
    t.string   "highschool"
    t.string   "about_yourself"
    t.string   "contact_number"
    t.string   "authentication_token"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.string   "image"
    t.string   "oauth_expires_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "wednesdays", :force => true do |t|
    t.string   "user_id"
    t.string   "zero"
    t.string   "one"
    t.string   "two"
    t.string   "three"
    t.string   "four"
    t.string   "five"
    t.string   "six"
    t.string   "seven"
    t.string   "eight"
    t.string   "nine"
    t.string   "ten"
    t.string   "eleven"
    t.string   "twelve"
    t.string   "thirteen"
    t.string   "fourteen"
    t.string   "fifteen"
    t.string   "sixteen"
    t.string   "seventeen"
    t.string   "eighteen"
    t.string   "nineteen"
    t.string   "twenty"
    t.string   "twentyone"
    t.string   "twentytwo"
    t.string   "twentythree"
    t.string   "twentyfour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
