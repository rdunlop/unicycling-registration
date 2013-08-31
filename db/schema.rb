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

ActiveRecord::Schema.define(:version => 20130830204848) do

  create_table "additional_registrant_accesses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "registrant_id"
    t.boolean  "declined"
    t.boolean  "accepted_readonly"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "additional_registrant_accesses", ["registrant_id"], :name => "index_additional_registrant_accesses_registrant_id"
  add_index "additional_registrant_accesses", ["user_id"], :name => "index_additional_registrant_accesses_user_id"

  create_table "age_group_entries", :force => true do |t|
    t.integer  "age_group_type_id"
    t.string   "short_description"
    t.string   "long_description"
    t.integer  "start_age"
    t.integer  "end_age"
    t.string   "gender"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "wheel_size_id"
  end

  add_index "age_group_entries", ["age_group_type_id"], :name => "index_age_group_entries_age_group_type_id"
  add_index "age_group_entries", ["wheel_size_id"], :name => "index_age_group_entries_wheel_size_id"

  create_table "age_group_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "award_labels", :force => true do |t|
    t.integer  "bib_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "partner_first_name"
    t.string   "partner_last_name"
    t.string   "competition_name"
    t.string   "team_name"
    t.string   "age_group"
    t.string   "gender"
    t.string   "details"
    t.integer  "place"
    t.integer  "user_id"
    t.integer  "registrant_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "boundary_scores", :force => true do |t|
    t.integer  "competitor_id"
    t.integer  "judge_id"
    t.integer  "number_of_people"
    t.integer  "major_dismount"
    t.integer  "minor_dismount"
    t.integer  "major_boundary"
    t.integer  "minor_boundary"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "boundary_scores", ["competitor_id"], :name => "index_boundary_scores_competitor_id"
  add_index "boundary_scores", ["judge_id"], :name => "index_boundary_scores_judge_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "info_url"
  end

  create_table "competitions", :force => true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.boolean  "locked"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "age_group_type_id"
    t.boolean  "has_experts",       :default => false
    t.boolean  "has_age_groups",    :default => false
  end

  add_index "competitions", ["event_id"], :name => "index_competitions_event_id"

  create_table "competitors", :force => true do |t|
    t.integer  "competition_id"
    t.integer  "position"
    t.integer  "custom_external_id"
    t.string   "custom_name"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "competitors", ["competition_id"], :name => "index_competitors_event_category_id"

  create_table "distance_attempts", :force => true do |t|
    t.integer  "competitor_id"
    t.decimal  "distance",      :precision => 4, :scale => 0
    t.boolean  "fault"
    t.integer  "judge_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "distance_attempts", ["competitor_id"], :name => "index_distance_attempts_competitor_id"
  add_index "distance_attempts", ["judge_id"], :name => "index_distance_attempts_judge_id"

  create_table "event_categories", :force => true do |t|
    t.integer  "event_id"
    t.integer  "position"
    t.string   "name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "age_group_type_id"
    t.integer  "competition_id"
  end

  add_index "event_categories", ["age_group_type_id"], :name => "index_event_categories_age_group_type_id"
  add_index "event_categories", ["event_id", "position"], :name => "index_event_categories_event_id"

  create_table "event_choices", :force => true do |t|
    t.integer  "event_id"
    t.string   "export_name"
    t.string   "cell_type"
    t.string   "multiple_values"
    t.string   "label"
    t.integer  "position"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "autocomplete"
    t.boolean  "optional",        :default => false
    t.string   "tooltip"
  end

  add_index "event_choices", ["event_id", "position"], :name => "index_event_choices_event_id"

  create_table "event_configurations", :force => true do |t|
    t.string   "short_name"
    t.string   "long_name"
    t.string   "location"
    t.string   "dates_description"
    t.string   "event_url"
    t.date     "start_date"
    t.binary   "logo_binary"
    t.string   "contact_email"
    t.date     "artistic_closed_date"
    t.date     "standard_skill_closed_date"
    t.date     "tshirt_closed_date"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "logo_filename"
    t.string   "logo_type"
    t.boolean  "test_mode"
    t.string   "waiver_url"
    t.string   "comp_noncomp_url"
    t.boolean  "waiver"
    t.boolean  "standard_skill",             :default => false
    t.boolean  "usa",                        :default => false
    t.boolean  "iuf",                        :default => false
    t.string   "currency_code"
    t.text     "currency"
  end

  create_table "events", :force => true do |t|
    t.integer  "category_id"
    t.string   "export_name"
    t.integer  "position"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "name"
    t.string   "event_class"
    t.boolean  "visible"
  end

  add_index "events", ["category_id"], :name => "index_events_category_id"

  create_table "expense_groups", :force => true do |t|
    t.string   "group_name"
    t.boolean  "visible"
    t.integer  "position"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "info_url"
    t.string   "competitor_free_options"
    t.string   "noncompetitor_free_options"
  end

  create_table "expense_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "cost"
    t.string   "export_name"
    t.integer  "position"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "expense_group_id"
    t.boolean  "has_details"
    t.string   "details_label"
    t.integer  "maximum_available"
    t.decimal  "tax_percentage",    :precision => 5, :scale => 3, :default => 0.0
  end

  add_index "expense_items", ["expense_group_id"], :name => "index_expense_items_expense_group_id"

  create_table "external_results", :force => true do |t|
    t.integer  "competitor_id"
    t.string   "details"
    t.integer  "rank"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "import_results", :force => true do |t|
    t.integer  "user_id"
    t.string   "raw_data"
    t.integer  "bib_number"
    t.integer  "minutes"
    t.integer  "seconds"
    t.integer  "thousands"
    t.boolean  "disqualified"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "competition_id"
    t.integer  "rank"
    t.string   "details"
  end

  add_index "import_results", ["user_id"], :name => "index_imported_results_user_id"

  create_table "judge_types", :force => true do |t|
    t.string   "name"
    t.string   "val_1_description"
    t.string   "val_2_description"
    t.string   "val_3_description"
    t.string   "val_4_description"
    t.integer  "val_1_max"
    t.integer  "val_2_max"
    t.integer  "val_3_max"
    t.integer  "val_4_max"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "event_class"
    t.boolean  "boundary_calculation_enabled"
  end

  create_table "judges", :force => true do |t|
    t.integer  "competition_id"
    t.integer  "judge_type_id"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "judges", ["competition_id"], :name => "index_judges_event_category_id"
  add_index "judges", ["judge_type_id"], :name => "index_judges_judge_type_id"
  add_index "judges", ["user_id"], :name => "index_judges_user_id"

  create_table "lane_assignments", :force => true do |t|
    t.integer  "competition_id"
    t.integer  "registrant_id"
    t.integer  "heat"
    t.integer  "lane"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "members", :force => true do |t|
    t.integer  "competitor_id"
    t.integer  "registrant_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "members", ["competitor_id"], :name => "index_members_competitor_id"
  add_index "members", ["registrant_id"], :name => "index_members_registrant_id"

  create_table "payment_details", :force => true do |t|
    t.integer  "payment_id"
    t.integer  "registrant_id"
    t.decimal  "amount"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "expense_item_id"
    t.string   "details"
    t.boolean  "free",            :default => false
  end

  add_index "payment_details", ["expense_item_id"], :name => "index_payment_details_expense_item_id"
  add_index "payment_details", ["payment_id"], :name => "index_payment_details_payment_id"
  add_index "payment_details", ["registrant_id"], :name => "index_payment_details_registrant_id"

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "completed"
    t.boolean  "cancelled"
    t.string   "transaction_id"
    t.datetime "completed_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "payment_date"
    t.string   "note"
  end

  add_index "payments", ["user_id"], :name => "index_payments_user_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "registrant_choices", :force => true do |t|
    t.integer  "registrant_id"
    t.integer  "event_choice_id"
    t.string   "value"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "registrant_choices", ["event_choice_id"], :name => "index_registrant_choices_event_choice_id"
  add_index "registrant_choices", ["registrant_id"], :name => "index_registrant_choices_registrant_id"

  create_table "registrant_event_sign_ups", :force => true do |t|
    t.integer  "registrant_id"
    t.boolean  "signed_up"
    t.integer  "event_category_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "event_id"
  end

  add_index "registrant_event_sign_ups", ["event_category_id"], :name => "index_registrant_event_sign_ups_event_category_id"
  add_index "registrant_event_sign_ups", ["event_id"], :name => "index_registrant_event_sign_ups_event_id"
  add_index "registrant_event_sign_ups", ["registrant_id"], :name => "index_registrant_event_sign_ups_registrant_id"

  create_table "registrant_expense_items", :force => true do |t|
    t.integer  "registrant_id"
    t.integer  "expense_item_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "details"
    t.boolean  "free",            :default => false
  end

  add_index "registrant_expense_items", ["expense_item_id"], :name => "index_registrant_expense_items_expense_item_id"
  add_index "registrant_expense_items", ["registrant_id"], :name => "index_registrant_expense_items_registrant_id"

  create_table "registrant_group_members", :force => true do |t|
    t.integer  "registrant_id"
    t.integer  "registrant_group_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "registrant_group_members", ["registrant_group_id"], :name => "index_registrant_group_mumbers_registrant_group_id"
  add_index "registrant_group_members", ["registrant_id"], :name => "index_registrant_group_mumbers_registrant_id"

  create_table "registrant_groups", :force => true do |t|
    t.string   "name"
    t.integer  "registrant_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "registrant_groups", ["registrant_id"], :name => "index_registrant_groups_registrant_id"

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
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
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
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.boolean  "deleted"
    t.integer  "bib_number"
    t.integer  "wheel_size_id"
    t.integer  "age"
    t.boolean  "ineligible",              :default => false
    t.boolean  "volunteer"
  end

  add_index "registrants", ["deleted"], :name => "index_registrants_deleted"

  create_table "registration_periods", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "competitor_expense_item_id"
    t.integer  "noncompetitor_expense_item_id"
    t.boolean  "onsite"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "scores", :force => true do |t|
    t.integer  "competitor_id"
    t.decimal  "val_1",         :precision => 5, :scale => 3
    t.decimal  "val_2",         :precision => 5, :scale => 3
    t.decimal  "val_3",         :precision => 5, :scale => 3
    t.decimal  "val_4",         :precision => 5, :scale => 3
    t.text     "notes"
    t.integer  "judge_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "scores", ["competitor_id"], :name => "index_scores_competitor_id"
  add_index "scores", ["judge_id"], :name => "index_scores_judge_id"

  create_table "standard_difficulty_scores", :force => true do |t|
    t.integer  "competitor_id"
    t.integer  "standard_skill_routine_entry_id"
    t.integer  "judge_id"
    t.integer  "devaluation"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "standard_execution_scores", :force => true do |t|
    t.integer  "competitor_id"
    t.integer  "standard_skill_routine_entry_id"
    t.integer  "judge_id"
    t.integer  "wave"
    t.integer  "line"
    t.integer  "cross"
    t.integer  "circle"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "standard_skill_entries", :force => true do |t|
    t.integer  "number"
    t.string   "letter"
    t.decimal  "points",      :precision => 6, :scale => 2
    t.string   "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "standard_skill_routine_entries", :force => true do |t|
    t.integer  "standard_skill_routine_id"
    t.integer  "standard_skill_entry_id"
    t.integer  "position"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "standard_skill_routines", :force => true do |t|
    t.integer  "registrant_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "street_scores", :force => true do |t|
    t.integer  "competitor_id"
    t.integer  "judge_id"
    t.decimal  "val_1",         :precision => 5, :scale => 3
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "street_scores", ["competitor_id"], :name => "index_street_scores_competitor_id"
  add_index "street_scores", ["judge_id"], :name => "index_street_scores_judge_id"

  create_table "time_results", :force => true do |t|
    t.integer  "competitor_id"
    t.integer  "minutes"
    t.integer  "seconds"
    t.integer  "thousands"
    t.boolean  "disqualified"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "time_results", ["competitor_id"], :name => "index_time_results_on_event_category_id"

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
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

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

  create_table "wheel_sizes", :force => true do |t|
    t.integer  "position"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
