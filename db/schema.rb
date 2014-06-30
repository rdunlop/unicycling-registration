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

ActiveRecord::Schema.define(version: 20140630023241) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_registrant_accesses", force: true do |t|
    t.integer  "user_id"
    t.integer  "registrant_id"
    t.boolean  "declined"
    t.boolean  "accepted_readonly"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "additional_registrant_accesses", ["registrant_id"], name: "index_additional_registrant_accesses_registrant_id", using: :btree
  add_index "additional_registrant_accesses", ["user_id"], name: "index_additional_registrant_accesses_user_id", using: :btree

  create_table "age_group_entries", force: true do |t|
    t.integer  "age_group_type_id"
    t.string   "short_description"
    t.integer  "start_age"
    t.integer  "end_age"
    t.string   "gender"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "wheel_size_id"
    t.integer  "position"
  end

  add_index "age_group_entries", ["age_group_type_id"], name: "index_age_group_entries_age_group_type_id", using: :btree
  add_index "age_group_entries", ["wheel_size_id"], name: "index_age_group_entries_wheel_size_id", using: :btree

  create_table "age_group_types", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "award_labels", force: true do |t|
    t.integer  "bib_number"
    t.string   "competition_name"
    t.string   "team_name"
    t.string   "details"
    t.integer  "place"
    t.integer  "user_id"
    t.integer  "registrant_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "competitor_name"
    t.string   "category"
  end

  add_index "award_labels", ["user_id"], name: "index_award_labels_on_user_id", using: :btree

  create_table "boundary_scores", force: true do |t|
    t.integer  "competitor_id"
    t.integer  "judge_id"
    t.integer  "number_of_people"
    t.integer  "major_dismount"
    t.integer  "minor_dismount"
    t.integer  "major_boundary"
    t.integer  "minor_boundary"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "boundary_scores", ["competitor_id"], name: "index_boundary_scores_competitor_id", using: :btree
  add_index "boundary_scores", ["judge_id"], name: "index_boundary_scores_judge_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "info_url"
  end

  create_table "category_translations", force: true do |t|
    t.integer  "category_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "category_translations", ["category_id"], name: "index_category_translations_on_category_id", using: :btree
  add_index "category_translations", ["locale"], name: "index_category_translations_on_locale", using: :btree

  create_table "combined_competition_entries", force: true do |t|
    t.integer  "combined_competition_id"
    t.string   "abbreviation"
    t.boolean  "tie_breaker"
    t.integer  "points_1"
    t.integer  "points_2"
    t.integer  "points_3"
    t.integer  "points_4"
    t.integer  "points_5"
    t.integer  "points_6"
    t.integer  "points_7"
    t.integer  "points_8"
    t.integer  "points_9"
    t.integer  "points_10"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competition_id"
  end

  create_table "combined_competitions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_age_group_places",          default: false
    t.boolean  "percentage_based_calculations", default: false
  end

  create_table "competition_sources", force: true do |t|
    t.integer  "target_competition_id"
    t.integer  "event_category_id"
    t.integer  "competition_id"
    t.string   "gender_filter"
    t.integer  "max_place"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "min_age"
    t.integer  "max_age"
  end

  add_index "competition_sources", ["competition_id"], name: "index_competition_sources_competition_id", using: :btree
  add_index "competition_sources", ["event_category_id"], name: "index_competition_sources_event_category_id", using: :btree
  add_index "competition_sources", ["target_competition_id"], name: "index_competition_sources_target_competition_id", using: :btree

  create_table "competitions", force: true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.boolean  "locked"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "age_group_type_id"
    t.boolean  "has_experts",                   default: false
    t.string   "scoring_class"
    t.string   "start_data_type"
    t.string   "end_data_type"
    t.boolean  "uses_lane_assignments",         default: false
    t.datetime "scheduled_completion_at"
    t.boolean  "published",                     default: false
    t.boolean  "awarded",                       default: false
    t.string   "published_results_file"
    t.string   "award_title_name"
    t.string   "award_subtitle_name"
    t.datetime "published_date"
    t.string   "num_members_per_competitor"
    t.boolean  "automatic_competitor_creation", default: false
  end

  add_index "competitions", ["event_id"], name: "index_competitions_event_id", using: :btree

  create_table "competitors", force: true do |t|
    t.integer  "competition_id"
    t.integer  "position"
    t.string   "custom_name"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "status",                   default: 0
    t.integer  "lowest_member_bib_number"
    t.boolean  "geared",                   default: false
    t.integer  "wheel_size"
    t.string   "notes"
  end

  add_index "competitors", ["competition_id"], name: "index_competitors_event_category_id", using: :btree

  create_table "contact_details", force: true do |t|
    t.integer  "registrant_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country_residence"
    t.string   "country_representing"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "usa_confirmed_paid",              default: false
    t.integer  "usa_family_membership_holder_id"
  end

  add_index "contact_details", ["registrant_id"], name: "index_contact_details_registrant_id", using: :btree

  create_table "distance_attempts", force: true do |t|
    t.integer  "competitor_id"
    t.decimal  "distance",      precision: 4, scale: 0
    t.boolean  "fault"
    t.integer  "judge_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "distance_attempts", ["competitor_id"], name: "index_distance_attempts_competitor_id", using: :btree
  add_index "distance_attempts", ["judge_id"], name: "index_distance_attempts_judge_id", using: :btree

  create_table "event_categories", force: true do |t|
    t.integer  "event_id"
    t.integer  "position"
    t.string   "name"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "age_range_start", default: 0
    t.integer  "age_range_end",   default: 100
  end

  add_index "event_categories", ["event_id", "position"], name: "index_event_categories_event_id", using: :btree

  create_table "event_choice_translations", force: true do |t|
    t.integer  "event_choice_id"
    t.string   "locale"
    t.string   "label"
    t.string   "tooltip"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "event_choice_translations", ["event_choice_id"], name: "index_event_choice_translations_on_event_choice_id", using: :btree
  add_index "event_choice_translations", ["locale"], name: "index_event_choice_translations_on_locale", using: :btree

  create_table "event_choices", force: true do |t|
    t.integer  "event_id"
    t.string   "export_name"
    t.string   "cell_type"
    t.string   "multiple_values"
    t.string   "label"
    t.integer  "position"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "autocomplete"
    t.boolean  "optional",                    default: false
    t.string   "tooltip"
    t.integer  "optional_if_event_choice_id"
    t.integer  "required_if_event_choice_id"
  end

  add_index "event_choices", ["event_id", "position"], name: "index_event_choices_event_id", using: :btree

  create_table "event_configuration_translations", force: true do |t|
    t.integer  "event_configuration_id"
    t.string   "locale"
    t.string   "short_name"
    t.string   "long_name"
    t.string   "dates_description"
    t.string   "location"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "event_configuration_translations", ["event_configuration_id"], name: "index_8da8125feacb8971b8fc26e0e628b77608288047", using: :btree
  add_index "event_configuration_translations", ["locale"], name: "index_event_configuration_translations_on_locale", using: :btree

  create_table "event_configurations", force: true do |t|
    t.string   "short_name"
    t.string   "long_name"
    t.string   "location"
    t.string   "dates_description"
    t.string   "event_url"
    t.date     "start_date"
    t.string   "contact_email"
    t.date     "artistic_closed_date"
    t.date     "standard_skill_closed_date"
    t.date     "tshirt_closed_date"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "test_mode"
    t.string   "waiver_url"
    t.string   "comp_noncomp_url"
    t.boolean  "has_print_waiver"
    t.boolean  "standard_skill",                        default: false
    t.boolean  "usa",                                   default: false
    t.boolean  "iuf",                                   default: false
    t.string   "currency_code"
    t.text     "currency"
    t.string   "rulebook_url"
    t.string   "style_name"
    t.boolean  "has_online_waiver"
    t.text     "online_waiver_text"
    t.date     "music_submission_end_date"
    t.boolean  "artistic_score_elimination_mode_naucc", default: true
    t.integer  "usa_individual_expense_item_id"
    t.integer  "usa_family_expense_item_id"
    t.string   "logo_file"
  end

  create_table "events", force: true do |t|
    t.integer  "category_id"
    t.string   "export_name"
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "name"
    t.boolean  "visible"
    t.boolean  "accepts_music_uploads", default: false
    t.boolean  "artistic",              default: false
  end

  add_index "events", ["category_id"], name: "index_events_category_id", using: :btree

  create_table "expense_group_translations", force: true do |t|
    t.integer  "expense_group_id"
    t.string   "locale"
    t.string   "group_name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "expense_group_translations", ["expense_group_id"], name: "index_expense_group_translations_on_expense_group_id", using: :btree
  add_index "expense_group_translations", ["locale"], name: "index_expense_group_translations_on_locale", using: :btree

  create_table "expense_groups", force: true do |t|
    t.string   "group_name"
    t.boolean  "visible"
    t.integer  "position"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "info_url"
    t.string   "competitor_free_options"
    t.string   "noncompetitor_free_options"
    t.boolean  "competitor_required",        default: false
    t.boolean  "noncompetitor_required",     default: false
  end

  create_table "expense_item_translations", force: true do |t|
    t.integer  "expense_item_id"
    t.string   "locale"
    t.string   "name"
    t.string   "description"
    t.string   "details_label"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "expense_item_translations", ["expense_item_id"], name: "index_expense_item_translations_on_expense_item_id", using: :btree
  add_index "expense_item_translations", ["locale"], name: "index_expense_item_translations_on_locale", using: :btree

  create_table "expense_items", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "cost"
    t.string   "export_name"
    t.integer  "position"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "expense_group_id"
    t.boolean  "has_details"
    t.string   "details_label"
    t.integer  "maximum_available"
    t.decimal  "tax_percentage",         precision: 5, scale: 3, default: 0.0
    t.boolean  "has_custom_cost",                                default: false
    t.integer  "maximum_per_registrant",                         default: 0
  end

  add_index "expense_items", ["expense_group_id"], name: "index_expense_items_expense_group_id", using: :btree

  create_table "external_results", force: true do |t|
    t.integer  "competitor_id"
    t.string   "details"
    t.decimal  "points",        precision: 6, scale: 3, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "external_results", ["competitor_id"], name: "index_external_results_on_competitor_id", using: :btree

  create_table "import_results", force: true do |t|
    t.integer  "user_id"
    t.string   "raw_data"
    t.integer  "bib_number"
    t.integer  "minutes"
    t.integer  "seconds"
    t.integer  "thousands"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "competition_id"
    t.decimal  "points",         precision: 6, scale: 3
    t.string   "details"
    t.boolean  "is_start_time",                          default: false
    t.integer  "attempt_number"
    t.string   "status"
    t.text     "comments"
    t.string   "comments_by"
    t.integer  "heat"
    t.integer  "lane"
  end

  add_index "import_results", ["user_id"], name: "index_import_results_on_user_id", using: :btree
  add_index "import_results", ["user_id"], name: "index_imported_results_user_id", using: :btree

  create_table "judge_types", force: true do |t|
    t.string   "name"
    t.string   "val_1_description"
    t.string   "val_2_description"
    t.string   "val_3_description"
    t.string   "val_4_description"
    t.integer  "val_1_max"
    t.integer  "val_2_max"
    t.integer  "val_3_max"
    t.integer  "val_4_max"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "event_class"
    t.boolean  "boundary_calculation_enabled"
  end

  create_table "judges", force: true do |t|
    t.integer  "competition_id"
    t.integer  "judge_type_id"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "judges", ["competition_id"], name: "index_judges_event_category_id", using: :btree
  add_index "judges", ["judge_type_id"], name: "index_judges_judge_type_id", using: :btree
  add_index "judges", ["user_id"], name: "index_judges_user_id", using: :btree

  create_table "lane_assignments", force: true do |t|
    t.integer  "competition_id"
    t.integer  "heat"
    t.integer  "lane"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "competitor_id"
  end

  add_index "lane_assignments", ["competition_id"], name: "index_lane_assignments_on_competition_id", using: :btree

  create_table "members", force: true do |t|
    t.integer  "competitor_id"
    t.integer  "registrant_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "members", ["competitor_id"], name: "index_members_competitor_id", using: :btree
  add_index "members", ["registrant_id"], name: "index_members_registrant_id", using: :btree

  create_table "payment_details", force: true do |t|
    t.integer  "payment_id"
    t.integer  "registrant_id"
    t.decimal  "amount"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "expense_item_id"
    t.string   "details"
    t.boolean  "free",            default: false
  end

  add_index "payment_details", ["expense_item_id"], name: "index_payment_details_expense_item_id", using: :btree
  add_index "payment_details", ["payment_id"], name: "index_payment_details_payment_id", using: :btree
  add_index "payment_details", ["registrant_id"], name: "index_payment_details_registrant_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "user_id"
    t.boolean  "completed"
    t.boolean  "cancelled"
    t.string   "transaction_id"
    t.datetime "completed_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "payment_date"
    t.string   "note"
  end

  add_index "payments", ["user_id"], name: "index_payments_user_id", using: :btree

  create_table "published_age_group_entries", force: true do |t|
    t.integer  "competition_id"
    t.integer  "age_group_entry_id"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "refund_details", force: true do |t|
    t.integer  "refund_id"
    t.integer  "payment_detail_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "refund_details", ["payment_detail_id"], name: "index_refund_details_on_payment_detail_id", using: :btree
  add_index "refund_details", ["refund_id"], name: "index_refund_details_on_refund_id", using: :btree

  create_table "refunds", force: true do |t|
    t.integer  "user_id"
    t.datetime "refund_date"
    t.string   "note"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "percentage",  default: 100
  end

  add_index "refunds", ["user_id"], name: "index_refunds_on_user_id", using: :btree

  create_table "registrant_choices", force: true do |t|
    t.integer  "registrant_id"
    t.integer  "event_choice_id"
    t.string   "value"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "registrant_choices", ["event_choice_id"], name: "index_registrant_choices_event_choice_id", using: :btree
  add_index "registrant_choices", ["registrant_id"], name: "index_registrant_choices_registrant_id", using: :btree

  create_table "registrant_event_sign_ups", force: true do |t|
    t.integer  "registrant_id"
    t.boolean  "signed_up"
    t.integer  "event_category_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "event_id"
  end

  add_index "registrant_event_sign_ups", ["event_category_id"], name: "index_registrant_event_sign_ups_event_category_id", using: :btree
  add_index "registrant_event_sign_ups", ["event_id"], name: "index_registrant_event_sign_ups_event_id", using: :btree
  add_index "registrant_event_sign_ups", ["registrant_id"], name: "index_registrant_event_sign_ups_registrant_id", using: :btree

  create_table "registrant_expense_items", force: true do |t|
    t.integer  "registrant_id"
    t.integer  "expense_item_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "details"
    t.boolean  "free",            default: false
    t.boolean  "system_managed",  default: false
    t.boolean  "locked",          default: false
    t.decimal  "custom_cost"
  end

  add_index "registrant_expense_items", ["expense_item_id"], name: "index_registrant_expense_items_expense_item_id", using: :btree
  add_index "registrant_expense_items", ["registrant_id"], name: "index_registrant_expense_items_registrant_id", using: :btree

  create_table "registrant_group_members", force: true do |t|
    t.integer  "registrant_id"
    t.integer  "registrant_group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "registrant_group_members", ["registrant_group_id"], name: "index_registrant_group_mumbers_registrant_group_id", using: :btree
  add_index "registrant_group_members", ["registrant_id"], name: "index_registrant_group_mumbers_registrant_id", using: :btree

  create_table "registrant_groups", force: true do |t|
    t.string   "name"
    t.integer  "registrant_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "registrant_groups", ["registrant_id"], name: "index_registrant_groups_registrant_id", using: :btree

  create_table "registrants", force: true do |t|
    t.string   "first_name"
    t.string   "middle_initial"
    t.string   "last_name"
    t.date     "birthday"
    t.string   "gender"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "user_id"
    t.boolean  "competitor"
    t.boolean  "deleted"
    t.integer  "bib_number"
    t.integer  "wheel_size_id"
    t.integer  "age"
    t.boolean  "ineligible",              default: false
    t.boolean  "volunteer"
    t.string   "online_waiver_signature"
  end

  add_index "registrants", ["deleted"], name: "index_registrants_deleted", using: :btree
  add_index "registrants", ["user_id"], name: "index_registrants_on_user_id", using: :btree

  create_table "registration_period_translations", force: true do |t|
    t.integer  "registration_period_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "registration_period_translations", ["locale"], name: "index_registration_period_translations_on_locale", using: :btree
  add_index "registration_period_translations", ["registration_period_id"], name: "index_43f042772e959a61bb6b1fedb770048039229050", using: :btree

  create_table "registration_periods", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "name"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "competitor_expense_item_id"
    t.integer  "noncompetitor_expense_item_id"
    t.boolean  "onsite"
    t.boolean  "current_period",                default: false
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "competitor_id"
    t.decimal  "val_1",         precision: 5, scale: 3
    t.decimal  "val_2",         precision: 5, scale: 3
    t.decimal  "val_3",         precision: 5, scale: 3
    t.decimal  "val_4",         precision: 5, scale: 3
    t.text     "notes"
    t.integer  "judge_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "scores", ["competitor_id"], name: "index_scores_competitor_id", using: :btree
  add_index "scores", ["judge_id"], name: "index_scores_judge_id", using: :btree

  create_table "songs", force: true do |t|
    t.integer  "registrant_id"
    t.string   "description"
    t.string   "song_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  add_index "songs", ["registrant_id"], name: "index_songs_registrant_id", using: :btree

  create_table "standard_difficulty_scores", force: true do |t|
    t.integer  "competitor_id"
    t.integer  "standard_skill_routine_entry_id"
    t.integer  "judge_id"
    t.integer  "devaluation"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "standard_execution_scores", force: true do |t|
    t.integer  "competitor_id"
    t.integer  "standard_skill_routine_entry_id"
    t.integer  "judge_id"
    t.integer  "wave"
    t.integer  "line"
    t.integer  "cross"
    t.integer  "circle"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "standard_skill_entries", force: true do |t|
    t.integer  "number"
    t.string   "letter"
    t.decimal  "points",      precision: 6, scale: 2
    t.string   "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "standard_skill_routine_entries", force: true do |t|
    t.integer  "standard_skill_routine_id"
    t.integer  "standard_skill_entry_id"
    t.integer  "position"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "standard_skill_routines", force: true do |t|
    t.integer  "registrant_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "time_results", force: true do |t|
    t.integer  "competitor_id"
    t.integer  "minutes"
    t.integer  "seconds"
    t.integer  "thousands"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_start_time",  default: false
    t.integer  "attempt_number"
    t.string   "status"
    t.text     "comments"
    t.string   "comments_by"
  end

  add_index "time_results", ["competitor_id"], name: "index_time_results_on_event_category_id", using: :btree

  create_table "two_attempt_entries", force: true do |t|
    t.integer  "user_id"
    t.integer  "competition_id"
    t.integer  "bib_number"
    t.integer  "minutes_1"
    t.integer  "minutes_2"
    t.integer  "seconds_1"
    t.string   "status_1"
    t.integer  "seconds_2"
    t.integer  "thousands_1"
    t.integer  "thousands_2"
    t.string   "status_2"
    t.boolean  "is_start_time",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.integer  "registrant_id"
    t.integer  "user_id"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "wheel_sizes", force: true do |t|
    t.integer  "position"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
