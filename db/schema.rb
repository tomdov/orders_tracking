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

ActiveRecord::Schema.define(:version => 20131207184800) do

  create_table "orders", :force => true do |t|
    t.text     "description"
    t.text     "site"
    t.date     "purchase_date"
    t.string   "status"
    t.date     "status_date"
    t.text     "notes"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "price"
    t.integer  "user_id"
  end

  add_index "orders", ["created_at"], :name => "index_orders_on_created_at"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",              :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
