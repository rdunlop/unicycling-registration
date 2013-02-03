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

ActiveRecord::Schema.define(:version => 20130203220900) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "info_url"
  end

  create_table "event_choices", :force => true do |t|
    t.integer  "event_id"
    t.string   "export_name"
    t.string   "cell_type"
    t.string   "multiple_values"
    t.string   "label"
    t.integer  "position"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "event_configurations", :force => true do |t|
    t.string   "short_name"
    t.string   "long_name"
    t.string   "location"
    t.string   "dates_description"
    t.string   "event_url"
    t.date     "start_date"
    t.binary   "logo_binary"
    t.string   "currency"
    t.string   "contact_email"
    t.boolean  "closed"
    t.date     "artistic_closed_date"
    t.date     "standard_skill_closed_date"
    t.date     "tshirt_closed_date"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "logo_filename"
    t.string   "logo_type"
    t.boolean  "test_mode"
    t.string   "waiver_url"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.string   "description"
    t.integer  "position"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "expense_groups", :force => true do |t|
    t.string   "group_name"
    t.boolean  "visible"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "expense_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "cost"
    t.string   "export_name"
    t.integer  "position"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "expense_group_id"
  end

  create_table "payment_details", :force => true do |t|
    t.integer  "payment_id"
    t.integer  "registrant_id"
    t.decimal  "amount"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "expense_item_id"
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "completed"
    t.boolean  "cancelled"
    t.string   "transaction_id"
    t.datetime "completed_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "registrant_choices", :force => true do |t|
    t.integer  "registrant_id"
    t.integer  "event_choice_id"
    t.string   "value"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "registrant_expense_items", :force => true do |t|
    t.integer  "registrant_id"
    t.integer  "expense_item_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "registrants", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_initial"
    t.string   "last_name"
    t.date     "birthday"
    t.string   "gender"
    t.string   "state"
    t.string   "country"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "user_id"
    t.boolean  "competitor"
    t.string   "club"
    t.string   "club_contact"
    t.string   "usa_member_number"
    t.string   "emergency_name"
    t.string   "emergency_relationship"
    t.boolean  "emergency_attending"
    t.string   "emergency_primary_phone"
    t.string   "emergency_other_phone"
    t.string   "responsible_adult_name"
    t.string   "responsible_adult_phone"
  end

  create_table "registration_periods", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "competitor_expense_item_id"
    t.integer  "noncompetitor_expense_item_id"
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "admin"
    t.boolean  "super_admin"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.integer  "registrant_id"
    t.integer  "user_id"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
