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

ActiveRecord::Schema.define(version: 20150708013054) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_registrant_accesses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "registrant_id"
    t.boolean  "declined",           default: false, null: false
    t.boolean  "accepted_readonly",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted_readwrite", default: false, null: false
  end

  add_index "additional_registrant_accesses", ["registrant_id", "user_id"], name: "ada_reg_user", unique: true, using: :btree
  add_index "additional_registrant_accesses", ["registrant_id"], name: "index_additional_registrant_accesses_registrant_id", using: :btree
  add_index "additional_registrant_accesses", ["user_id"], name: "index_additional_registrant_accesses_user_id", using: :btree

  create_table "age_group_entries", force: :cascade do |t|
    t.integer  "age_group_type_id"
    t.string   "short_description", limit: 255
    t.integer  "start_age"
    t.integer  "end_age"
    t.string   "gender",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wheel_size_id"
    t.integer  "position"
  end

  add_index "age_group_entries", ["age_group_type_id", "short_description"], name: "age_type_desc", unique: true, using: :btree
  add_index "age_group_entries", ["age_group_type_id"], name: "index_age_group_entries_age_group_type_id", using: :btree
  add_index "age_group_entries", ["wheel_size_id"], name: "index_age_group_entries_wheel_size_id", using: :btree

  create_table "age_group_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "age_group_types", ["name"], name: "index_age_group_types_on_name", unique: true, using: :btree

  create_table "award_labels", force: :cascade do |t|
    t.integer  "bib_number"
    t.string   "competition_name", limit: 255
    t.string   "team_name",        limit: 255
    t.string   "details",          limit: 255
    t.integer  "place"
    t.integer  "user_id"
    t.integer  "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "competitor_name",  limit: 255
    t.string   "category",         limit: 255
  end

  add_index "award_labels", ["user_id"], name: "index_award_labels_on_user_id", using: :btree

  create_table "boundary_scores", force: :cascade do |t|
    t.integer  "competitor_id"
    t.integer  "judge_id"
    t.integer  "number_of_people"
    t.integer  "major_dismount"
    t.integer  "minor_dismount"
    t.integer  "major_boundary"
    t.integer  "minor_boundary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boundary_scores", ["competitor_id"], name: "index_boundary_scores_competitor_id", using: :btree
  add_index "boundary_scores", ["judge_id", "competitor_id"], name: "index_boundary_scores_on_judge_id_and_competitor_id", unique: true, using: :btree
  add_index "boundary_scores", ["judge_id"], name: "index_boundary_scores_judge_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "info_url",   limit: 255
  end

  create_table "category_translations", force: :cascade do |t|
    t.integer  "category_id",             null: false
    t.string   "locale",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        limit: 255
  end

  add_index "category_translations", ["category_id"], name: "index_category_translations_on_category_id", using: :btree
  add_index "category_translations", ["locale"], name: "index_category_translations_on_locale", using: :btree

  create_table "combined_competition_entries", force: :cascade do |t|
    t.integer  "combined_competition_id"
    t.string   "abbreviation",            limit: 255
    t.boolean  "tie_breaker",                         default: false, null: false
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
    t.integer  "base_points"
  end

  create_table "combined_competitions", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_age_group_places",                      default: false, null: false
    t.boolean  "percentage_based_calculations",             default: false, null: false
  end

  add_index "combined_competitions", ["name"], name: "index_combined_competitions_on_name", unique: true, using: :btree

  create_table "competition_results", force: :cascade do |t|
    t.integer  "competition_id"
    t.string   "results_file",   limit: 255
    t.boolean  "system_managed",             default: false, null: false
    t.boolean  "published",                  default: false, null: false
    t.datetime "published_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           limit: 255
  end

  create_table "competition_sources", force: :cascade do |t|
    t.integer  "target_competition_id"
    t.integer  "event_category_id"
    t.integer  "competition_id"
    t.string   "gender_filter",         limit: 255, default: "Both", null: false
    t.integer  "max_place"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "min_age"
    t.integer  "max_age"
  end

  add_index "competition_sources", ["competition_id"], name: "index_competition_sources_competition_id", using: :btree
  add_index "competition_sources", ["event_category_id"], name: "index_competition_sources_event_category_id", using: :btree
  add_index "competition_sources", ["target_competition_id"], name: "index_competition_sources_target_competition_id", using: :btree

  create_table "competition_wheel_sizes", force: :cascade do |t|
    t.integer  "registrant_id"
    t.integer  "event_id"
    t.integer  "wheel_size_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "competition_wheel_sizes", ["registrant_id", "event_id"], name: "index_competition_wheel_sizes_on_registrant_id_and_event_id", unique: true, using: :btree
  add_index "competition_wheel_sizes", ["registrant_id", "event_id"], name: "index_competition_wheel_sizes_registrant_id_event_id", using: :btree

  create_table "competitions", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "name",                          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "age_group_type_id"
    t.boolean  "has_experts",                               default: false, null: false
    t.string   "scoring_class",                 limit: 255
    t.string   "start_data_type",               limit: 255
    t.string   "end_data_type",                 limit: 255
    t.boolean  "uses_lane_assignments",                     default: false, null: false
    t.datetime "scheduled_completion_at"
    t.boolean  "awarded",                                   default: false, null: false
    t.string   "award_title_name",              limit: 255
    t.string   "award_subtitle_name",           limit: 255
    t.string   "num_members_per_competitor",    limit: 255
    t.boolean  "automatic_competitor_creation",             default: false, null: false
    t.integer  "combined_competition_id"
    t.boolean  "order_finalized",                           default: false, null: false
    t.integer  "penalty_seconds"
    t.datetime "locked_at"
    t.datetime "published_at"
  end

  add_index "competitions", ["combined_competition_id"], name: "index_competitions_on_combined_competition_id", unique: true, using: :btree
  add_index "competitions", ["event_id"], name: "index_competitions_event_id", using: :btree

  create_table "competitors", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "position"
    t.string   "custom_name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                               default: 0
    t.integer  "lowest_member_bib_number"
    t.boolean  "geared",                               default: false, null: false
    t.integer  "riding_wheel_size"
    t.string   "notes",                    limit: 255
    t.integer  "wave"
    t.integer  "riding_crank_size"
  end

  add_index "competitors", ["competition_id"], name: "index_competitors_event_category_id", using: :btree

  create_table "contact_details", force: :cascade do |t|
    t.integer  "registrant_id"
    t.string   "address",                         limit: 255
    t.string   "city",                            limit: 255
    t.string   "state_code",                      limit: 255
    t.string   "zip",                             limit: 255
    t.string   "country_residence",               limit: 255
    t.string   "country_representing",            limit: 255
    t.string   "phone",                           limit: 255
    t.string   "mobile",                          limit: 255
    t.string   "email",                           limit: 255
    t.string   "club",                            limit: 255
    t.string   "club_contact",                    limit: 255
    t.string   "usa_member_number",               limit: 255
    t.string   "emergency_name",                  limit: 255
    t.string   "emergency_relationship",          limit: 255
    t.boolean  "emergency_attending",                         default: false, null: false
    t.string   "emergency_primary_phone",         limit: 255
    t.string   "emergency_other_phone",           limit: 255
    t.string   "responsible_adult_name",          limit: 255
    t.string   "responsible_adult_phone",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "usa_confirmed_paid",                          default: false, null: false
    t.integer  "usa_family_membership_holder_id"
    t.string   "birthplace"
    t.string   "italian_fiscal_code"
  end

  add_index "contact_details", ["registrant_id"], name: "index_contact_details_on_registrant_id", unique: true, using: :btree
  add_index "contact_details", ["registrant_id"], name: "index_contact_details_registrant_id", using: :btree

  create_table "coupon_code_expense_items", force: :cascade do |t|
    t.integer  "coupon_code_id"
    t.integer  "expense_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_codes", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "code",          limit: 255
    t.string   "description",   limit: 255
    t.integer  "max_num_uses",              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "inform_emails"
    t.integer  "price_cents"
  end

  create_table "distance_attempts", force: :cascade do |t|
    t.integer  "competitor_id"
    t.decimal  "distance",      precision: 4
    t.boolean  "fault",                       default: false, null: false
    t.integer  "judge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distance_attempts", ["competitor_id"], name: "index_distance_attempts_competitor_id", using: :btree
  add_index "distance_attempts", ["judge_id"], name: "index_distance_attempts_judge_id", using: :btree

  create_table "event_categories", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "position"
    t.string   "name",                            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "age_range_start",                             default: 0
    t.integer  "age_range_end",                               default: 100
    t.boolean  "warning_on_registration_summary",             default: false, null: false
  end

  add_index "event_categories", ["event_id", "name"], name: "index_event_categories_on_event_id_and_name", unique: true, using: :btree
  add_index "event_categories", ["event_id", "position"], name: "index_event_categories_event_id", using: :btree

  create_table "event_choice_translations", force: :cascade do |t|
    t.integer  "event_choice_id",             null: false
    t.string   "locale",          limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",           limit: 255
    t.string   "tooltip",         limit: 255
  end

  add_index "event_choice_translations", ["event_choice_id"], name: "index_event_choice_translations_on_event_choice_id", using: :btree
  add_index "event_choice_translations", ["locale"], name: "index_event_choice_translations_on_locale", using: :btree

  create_table "event_choices", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "cell_type",                   limit: 255
    t.string   "multiple_values",             limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "optional",                                default: false, null: false
    t.integer  "optional_if_event_choice_id"
    t.integer  "required_if_event_choice_id"
  end

  create_table "event_configuration_translations", force: :cascade do |t|
    t.integer  "event_configuration_id",                  null: false
    t.string   "locale",                      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name",                  limit: 255
    t.string   "long_name",                   limit: 255
    t.string   "location",                    limit: 255
    t.string   "dates_description",           limit: 255
    t.text     "competitor_benefits"
    t.text     "noncompetitor_benefits"
    t.text     "spectator_benefits"
    t.text     "offline_payment_description"
  end

  add_index "event_configuration_translations", ["event_configuration_id"], name: "index_8da8125feacb8971b8fc26e0e628b77608288047", using: :btree
  add_index "event_configuration_translations", ["locale"], name: "index_event_configuration_translations_on_locale", using: :btree

  create_table "event_configurations", force: :cascade do |t|
    t.string   "event_url",                             limit: 255
    t.date     "start_date"
    t.string   "contact_email",                         limit: 255
    t.date     "artistic_closed_date"
    t.date     "standard_skill_closed_date"
    t.date     "event_sign_up_closed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "test_mode",                                         default: false,      null: false
    t.string   "comp_noncomp_url",                      limit: 255
    t.boolean  "standard_skill",                                    default: false,      null: false
    t.boolean  "usa",                                               default: false,      null: false
    t.boolean  "iuf",                                               default: false,      null: false
    t.string   "currency_code",                         limit: 255
    t.string   "rulebook_url",                          limit: 255
    t.string   "style_name",                            limit: 255
    t.text     "custom_waiver_text"
    t.date     "music_submission_end_date"
    t.boolean  "artistic_score_elimination_mode_naucc",             default: true,       null: false
    t.integer  "usa_individual_expense_item_id"
    t.integer  "usa_family_expense_item_id"
    t.string   "logo_file",                             limit: 255
    t.integer  "max_award_place",                                   default: 5
    t.boolean  "display_confirmed_events",                          default: false,      null: false
    t.boolean  "spectators",                                        default: false,      null: false
    t.boolean  "usa_membership_config",                             default: false,      null: false
    t.string   "paypal_account",                        limit: 255
    t.string   "waiver",                                            default: "none"
    t.integer  "validations_applied"
    t.boolean  "italian_requirements",                              default: false,      null: false
    t.string   "rules_file_name"
    t.boolean  "accept_rules",                                      default: false,      null: false
    t.string   "paypal_mode",                                       default: "disabled"
    t.boolean  "offline_payment",                                   default: false,      null: false
    t.string   "enabled_locales",                                   default: "en,fr",    null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                        limit: 255
    t.boolean  "visible",                                 default: true,  null: false
    t.boolean  "accepts_music_uploads",                   default: false, null: false
    t.boolean  "artistic",                                default: false, null: false
    t.boolean  "accepts_wheel_size_override",             default: false, null: false
    t.integer  "event_categories_count",                  default: 0,     null: false
    t.integer  "event_choices_count",                     default: 0,     null: false
  end

  add_index "events", ["accepts_wheel_size_override"], name: "index_events_on_accepts_wheel_size_override", using: :btree
  add_index "events", ["category_id"], name: "index_events_category_id", using: :btree

  create_table "expense_group_translations", force: :cascade do |t|
    t.integer  "expense_group_id",             null: false
    t.string   "locale",           limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_name",       limit: 255
  end

  add_index "expense_group_translations", ["expense_group_id"], name: "index_expense_group_translations_on_expense_group_id", using: :btree
  add_index "expense_group_translations", ["locale"], name: "index_expense_group_translations_on_locale", using: :btree

  create_table "expense_groups", force: :cascade do |t|
    t.boolean  "visible",                                default: true,  null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "info_url",                   limit: 255
    t.string   "competitor_free_options",    limit: 255
    t.string   "noncompetitor_free_options", limit: 255
    t.boolean  "competitor_required",                    default: false, null: false
    t.boolean  "noncompetitor_required",                 default: false, null: false
    t.boolean  "registration_items",                     default: false, null: false
  end

  create_table "expense_item_translations", force: :cascade do |t|
    t.integer  "expense_item_id",             null: false
    t.string   "locale",          limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",            limit: 255
    t.string   "details_label",   limit: 255
  end

  add_index "expense_item_translations", ["expense_item_id"], name: "index_expense_item_translations_on_expense_item_id", using: :btree
  add_index "expense_item_translations", ["locale"], name: "index_expense_item_translations_on_locale", using: :btree

  create_table "expense_items", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expense_group_id"
    t.boolean  "has_details",            default: false, null: false
    t.integer  "maximum_available"
    t.boolean  "has_custom_cost",        default: false, null: false
    t.integer  "maximum_per_registrant", default: 0
    t.integer  "cost_cents"
    t.integer  "tax_cents",              default: 0,     null: false
  end

  add_index "expense_items", ["expense_group_id"], name: "index_expense_items_expense_group_id", using: :btree

  create_table "external_results", force: :cascade do |t|
    t.integer  "competitor_id"
    t.string   "details",       limit: 255
    t.decimal  "points",                    precision: 6, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entered_by_id",                                     null: false
    t.datetime "entered_at",                                        null: false
    t.string   "status",                                            null: false
    t.boolean  "preliminary",                                       null: false
  end

  add_index "external_results", ["competitor_id"], name: "index_external_results_on_competitor_id", unique: true, using: :btree

  create_table "import_results", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "raw_data",            limit: 255
    t.integer  "bib_number"
    t.integer  "minutes"
    t.integer  "seconds"
    t.integer  "thousands"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competition_id"
    t.decimal  "points",                          precision: 6, scale: 3
    t.string   "details",             limit: 255
    t.boolean  "is_start_time",                                           default: false, null: false
    t.integer  "number_of_laps"
    t.string   "status",              limit: 255
    t.text     "comments"
    t.string   "comments_by",         limit: 255
    t.integer  "heat"
    t.integer  "lane"
    t.integer  "number_of_penalties"
  end

  add_index "import_results", ["user_id"], name: "index_import_results_on_user_id", using: :btree
  add_index "import_results", ["user_id"], name: "index_imported_results_user_id", using: :btree

  create_table "judge_types", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.string   "val_1_description",            limit: 255
    t.string   "val_2_description",            limit: 255
    t.string   "val_3_description",            limit: 255
    t.string   "val_4_description",            limit: 255
    t.integer  "val_1_max"
    t.integer  "val_2_max"
    t.integer  "val_3_max"
    t.integer  "val_4_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event_class",                  limit: 255
    t.boolean  "boundary_calculation_enabled",             default: false, null: false
  end

  add_index "judge_types", ["name", "event_class"], name: "index_judge_types_on_name_and_event_class", unique: true, using: :btree

  create_table "judges", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "judge_type_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",         default: "active", null: false
  end

  add_index "judges", ["competition_id"], name: "index_judges_event_category_id", using: :btree
  add_index "judges", ["judge_type_id", "competition_id", "user_id"], name: "index_judges_on_judge_type_id_and_competition_id_and_user_id", unique: true, using: :btree
  add_index "judges", ["judge_type_id"], name: "index_judges_judge_type_id", using: :btree
  add_index "judges", ["user_id"], name: "index_judges_user_id", using: :btree

  create_table "lane_assignments", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "heat"
    t.integer  "lane"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competitor_id"
  end

  add_index "lane_assignments", ["competition_id", "heat", "lane"], name: "index_lane_assignments_on_competition_id_and_heat_and_lane", unique: true, using: :btree
  add_index "lane_assignments", ["competition_id"], name: "index_lane_assignments_on_competition_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.integer  "competitor_id"
    t.integer  "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dropped_from_registration", default: false, null: false
  end

  add_index "members", ["competitor_id"], name: "index_members_competitor_id", using: :btree
  add_index "members", ["registrant_id"], name: "index_members_registrant_id", using: :btree

  create_table "payment_detail_coupon_codes", force: :cascade do |t|
    t.integer  "payment_detail_id"
    t.integer  "coupon_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_details", force: :cascade do |t|
    t.integer  "payment_id"
    t.integer  "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expense_item_id"
    t.string   "details",         limit: 255
    t.boolean  "free",                        default: false, null: false
    t.boolean  "refunded",                    default: false, null: false
    t.integer  "amount_cents"
  end

  add_index "payment_details", ["expense_item_id"], name: "index_payment_details_expense_item_id", using: :btree
  add_index "payment_details", ["payment_id"], name: "index_payment_details_payment_id", using: :btree
  add_index "payment_details", ["registrant_id"], name: "index_payment_details_registrant_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "completed",                  default: false, null: false
    t.boolean  "cancelled",                  default: false, null: false
    t.string   "transaction_id", limit: 255
    t.datetime "completed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_date",   limit: 255
    t.string   "note",           limit: 255
    t.string   "invoice_id",     limit: 255
  end

  add_index "payments", ["user_id"], name: "index_payments_user_id", using: :btree

  create_table "published_age_group_entries", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "age_group_entry_id"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username",   limit: 255
    t.integer  "item"
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "refund_details", force: :cascade do |t|
    t.integer  "refund_id"
    t.integer  "payment_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refund_details", ["payment_detail_id"], name: "index_refund_details_on_payment_detail_id", unique: true, using: :btree
  add_index "refund_details", ["refund_id"], name: "index_refund_details_on_refund_id", using: :btree

  create_table "refunds", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "refund_date"
    t.string   "note",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percentage",              default: 100
  end

  add_index "refunds", ["user_id"], name: "index_refunds_on_user_id", using: :btree

  create_table "registrant_choices", force: :cascade do |t|
    t.integer  "registrant_id"
    t.integer  "event_choice_id"
    t.string   "value",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrant_choices", ["event_choice_id"], name: "index_registrant_choices_event_choice_id", using: :btree
  add_index "registrant_choices", ["registrant_id", "event_choice_id"], name: "index_registrant_choices_on_registrant_id_and_event_choice_id", unique: true, using: :btree
  add_index "registrant_choices", ["registrant_id"], name: "index_registrant_choices_registrant_id", using: :btree

  create_table "registrant_event_sign_ups", force: :cascade do |t|
    t.integer  "registrant_id"
    t.boolean  "signed_up",         default: false, null: false
    t.integer  "event_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  add_index "registrant_event_sign_ups", ["event_category_id"], name: "index_registrant_event_sign_ups_event_category_id", using: :btree
  add_index "registrant_event_sign_ups", ["event_id"], name: "index_registrant_event_sign_ups_event_id", using: :btree
  add_index "registrant_event_sign_ups", ["registrant_id", "event_id"], name: "index_registrant_event_sign_ups_on_registrant_id_and_event_id", unique: true, using: :btree
  add_index "registrant_event_sign_ups", ["registrant_id"], name: "index_registrant_event_sign_ups_registrant_id", using: :btree

  create_table "registrant_expense_items", force: :cascade do |t|
    t.integer  "registrant_id"
    t.integer  "expense_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "details",           limit: 255
    t.boolean  "free",                          default: false, null: false
    t.boolean  "system_managed",                default: false, null: false
    t.boolean  "locked",                        default: false, null: false
    t.integer  "custom_cost_cents"
  end

  add_index "registrant_expense_items", ["expense_item_id"], name: "index_registrant_expense_items_expense_item_id", using: :btree
  add_index "registrant_expense_items", ["registrant_id"], name: "index_registrant_expense_items_registrant_id", using: :btree

  create_table "registrant_group_members", force: :cascade do |t|
    t.integer  "registrant_id"
    t.integer  "registrant_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrant_group_members", ["registrant_group_id"], name: "index_registrant_group_mumbers_registrant_group_id", using: :btree
  add_index "registrant_group_members", ["registrant_id", "registrant_group_id"], name: "reg_group_reg_group", unique: true, using: :btree
  add_index "registrant_group_members", ["registrant_id"], name: "index_registrant_group_mumbers_registrant_id", using: :btree

  create_table "registrant_groups", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrant_groups", ["registrant_id"], name: "index_registrant_groups_registrant_id", using: :btree

  create_table "registrants", force: :cascade do |t|
    t.string   "first_name",              limit: 255
    t.string   "middle_initial",          limit: 255
    t.string   "last_name",               limit: 255
    t.date     "birthday"
    t.string   "gender",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "deleted",                             default: false,        null: false
    t.integer  "bib_number"
    t.integer  "wheel_size_id"
    t.integer  "age"
    t.boolean  "ineligible",                          default: false,        null: false
    t.boolean  "volunteer",                           default: false,        null: false
    t.string   "online_waiver_signature", limit: 255
    t.string   "access_code",             limit: 255
    t.string   "sorted_last_name",        limit: 255
    t.string   "status",                  limit: 255, default: "active",     null: false
    t.string   "registrant_type",         limit: 255, default: "competitor"
    t.boolean  "rules_accepted",                      default: false,        null: false
  end

  add_index "registrants", ["deleted"], name: "index_registrants_deleted", using: :btree
  add_index "registrants", ["registrant_type"], name: "index_registrants_on_registrant_type", using: :btree
  add_index "registrants", ["user_id"], name: "index_registrants_on_user_id", using: :btree

  create_table "registration_period_translations", force: :cascade do |t|
    t.integer  "registration_period_id",             null: false
    t.string   "locale",                 limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255
  end

  add_index "registration_period_translations", ["locale"], name: "index_registration_period_translations_on_locale", using: :btree
  add_index "registration_period_translations", ["registration_period_id"], name: "index_43f042772e959a61bb6b1fedb770048039229050", using: :btree

  create_table "registration_periods", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competitor_expense_item_id"
    t.integer  "noncompetitor_expense_item_id"
    t.boolean  "onsite",                        default: false, null: false
    t.boolean  "current_period",                default: false, null: false
  end

  create_table "results", force: :cascade do |t|
    t.integer  "competitor_id"
    t.string   "result_type",    limit: 255
    t.integer  "result_subtype"
    t.integer  "place"
    t.string   "status",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "results", ["competitor_id", "result_type"], name: "index_results_on_competitor_id_and_result_type", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer  "competitor_id"
    t.decimal  "val_1",         precision: 5, scale: 3
    t.decimal  "val_2",         precision: 5, scale: 3
    t.decimal  "val_3",         precision: 5, scale: 3
    t.decimal  "val_4",         precision: 5, scale: 3
    t.text     "notes"
    t.integer  "judge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["competitor_id", "judge_id"], name: "index_scores_on_competitor_id_and_judge_id", unique: true, using: :btree
  add_index "scores", ["competitor_id"], name: "index_scores_competitor_id", using: :btree
  add_index "scores", ["judge_id"], name: "index_scores_judge_id", using: :btree

  create_table "songs", force: :cascade do |t|
    t.integer  "registrant_id"
    t.string   "description",    limit: 255
    t.string   "song_file_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "competitor_id"
  end

  add_index "songs", ["competitor_id"], name: "index_songs_on_competitor_id", unique: true, using: :btree
  add_index "songs", ["registrant_id"], name: "index_songs_registrant_id", using: :btree
  add_index "songs", ["user_id", "registrant_id", "event_id"], name: "index_songs_on_user_id_and_registrant_id_and_event_id", unique: true, using: :btree

  create_table "standard_difficulty_scores", force: :cascade do |t|
    t.integer  "competitor_id"
    t.integer  "standard_skill_routine_entry_id"
    t.integer  "judge_id"
    t.integer  "devaluation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "standard_difficulty_scores", ["judge_id", "standard_skill_routine_entry_id", "competitor_id"], name: "standard_diff_judge_routine_comp", unique: true, using: :btree

  create_table "standard_execution_scores", force: :cascade do |t|
    t.integer  "competitor_id"
    t.integer  "standard_skill_routine_entry_id"
    t.integer  "judge_id"
    t.integer  "wave"
    t.integer  "line"
    t.integer  "cross"
    t.integer  "circle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "standard_execution_scores", ["judge_id", "standard_skill_routine_entry_id", "competitor_id"], name: "standard_exec_judge_routine_comp", unique: true, using: :btree

  create_table "standard_skill_entries", force: :cascade do |t|
    t.integer  "number"
    t.string   "letter",      limit: 255
    t.decimal  "points",                  precision: 6, scale: 2
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "standard_skill_entries", ["letter", "number"], name: "index_standard_skill_entries_on_letter_and_number", unique: true, using: :btree

  create_table "standard_skill_routine_entries", force: :cascade do |t|
    t.integer  "standard_skill_routine_id"
    t.integer  "standard_skill_entry_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "standard_skill_routines", force: :cascade do |t|
    t.integer  "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "standard_skill_routines", ["registrant_id"], name: "index_standard_skill_routines_on_registrant_id", unique: true, using: :btree

  create_table "tenant_aliases", force: :cascade do |t|
    t.integer  "tenant_id",                                  null: false
    t.string   "website_alias",  limit: 255,                 null: false
    t.boolean  "primary_domain",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified",                   default: false, null: false
  end

  add_index "tenant_aliases", ["tenant_id", "primary_domain"], name: "index_tenant_aliases_on_tenant_id_and_primary_domain", using: :btree
  add_index "tenant_aliases", ["website_alias"], name: "index_tenant_aliases_on_website_alias", using: :btree

  create_table "tenants", force: :cascade do |t|
    t.string   "subdomain",          limit: 255
    t.string   "description",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_upgrade_code", limit: 255
  end

  add_index "tenants", ["subdomain"], name: "index_tenants_on_subdomain", using: :btree

  create_table "tie_break_adjustments", force: :cascade do |t|
    t.integer  "tie_break_place"
    t.integer  "judge_id"
    t.integer  "competitor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tie_break_adjustments", ["competitor_id", "judge_id"], name: "index_tie_break_adjustments_on_competitor_id_and_judge_id", unique: true, using: :btree
  add_index "tie_break_adjustments", ["competitor_id"], name: "index_tie_break_adjustments_competitor_id", using: :btree
  add_index "tie_break_adjustments", ["competitor_id"], name: "index_tie_break_adjustments_on_competitor_id", unique: true, using: :btree
  add_index "tie_break_adjustments", ["judge_id"], name: "index_tie_break_adjustments_judge_id", using: :btree

  create_table "time_results", force: :cascade do |t|
    t.integer  "competitor_id"
    t.integer  "minutes"
    t.integer  "seconds"
    t.integer  "thousands"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_start_time",                   default: false, null: false
    t.integer  "number_of_laps"
    t.string   "status",              limit: 255,                 null: false
    t.text     "comments"
    t.string   "comments_by",         limit: 255
    t.integer  "number_of_penalties"
    t.datetime "entered_at",                                      null: false
    t.integer  "entered_by_id",                                   null: false
    t.boolean  "preliminary"
  end

  add_index "time_results", ["competitor_id"], name: "index_time_results_on_competitor_id", using: :btree

  create_table "tolk_locales", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_locales", ["name"], name: "index_tolk_locales_on_name", unique: true, using: :btree

  create_table "tolk_phrases", force: :cascade do |t|
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", force: :cascade do |t|
    t.integer  "phrase_id"
    t.integer  "locale_id"
    t.text     "text"
    t.text     "previous_text"
    t.boolean  "primary_updated", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_translations", ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true, using: :btree

  create_table "two_attempt_entries", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "competition_id"
    t.integer  "bib_number"
    t.integer  "minutes_1"
    t.integer  "minutes_2"
    t.integer  "seconds_1"
    t.string   "status_1",       limit: 255
    t.integer  "seconds_2"
    t.integer  "thousands_1"
    t.integer  "thousands_2"
    t.string   "status_2",       limit: 255
    t.boolean  "is_start_time",              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255
    t.boolean  "guest",                              default: false, null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.integer  "registrant_id"
    t.integer  "user_id"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "volunteer_choices", force: :cascade do |t|
    t.integer  "registrant_id",            null: false
    t.integer  "volunteer_opportunity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "volunteer_choices", ["registrant_id", "volunteer_opportunity_id"], name: "volunteer_choices_reg_vol_opt_unique", unique: true, using: :btree
  add_index "volunteer_choices", ["registrant_id"], name: "index_volunteer_choices_on_registrant_id", using: :btree
  add_index "volunteer_choices", ["volunteer_opportunity_id"], name: "index_volunteer_choices_on_volunteer_opportunity_id", using: :btree

  create_table "volunteer_opportunities", force: :cascade do |t|
    t.string   "description",   limit: 255, null: false
    t.integer  "position"
    t.text     "inform_emails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "volunteer_opportunities", ["description"], name: "index_volunteer_opportunities_on_description", unique: true, using: :btree
  add_index "volunteer_opportunities", ["position"], name: "index_volunteer_opportunities_on_position", using: :btree

  create_table "wave_times", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "wave"
    t.integer  "minutes"
    t.integer  "seconds"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scheduled_time", limit: 255
  end

  add_index "wave_times", ["competition_id", "wave"], name: "index_wave_times_on_competition_id_and_wave", unique: true, using: :btree

  create_table "wheel_sizes", force: :cascade do |t|
    t.integer  "position"
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
