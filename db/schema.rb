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

ActiveRecord::Schema.define(version: 20171221025728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_registrant_accesses", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "registrant_id"
    t.boolean "declined", default: false, null: false
    t.boolean "accepted_readonly", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "accepted_readwrite", default: false, null: false
    t.index ["registrant_id", "user_id"], name: "ada_reg_user", unique: true
    t.index ["registrant_id"], name: "index_additional_registrant_accesses_registrant_id"
    t.index ["user_id"], name: "index_additional_registrant_accesses_user_id"
  end

  create_table "age_group_entries", id: :serial, force: :cascade do |t|
    t.integer "age_group_type_id"
    t.string "short_description", limit: 255
    t.integer "start_age"
    t.integer "end_age"
    t.string "gender", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "wheel_size_id"
    t.integer "position"
    t.index ["age_group_type_id", "short_description"], name: "age_type_desc", unique: true
    t.index ["age_group_type_id"], name: "index_age_group_entries_age_group_type_id"
    t.index ["wheel_size_id"], name: "index_age_group_entries_wheel_size_id"
  end

  create_table "age_group_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_age_group_types_on_name", unique: true
  end

  create_table "award_labels", id: :serial, force: :cascade do |t|
    t.integer "bib_number"
    t.string "line_2", limit: 255
    t.string "line_3", limit: 255
    t.string "line_5", limit: 255
    t.integer "place"
    t.integer "user_id"
    t.integer "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "line_1", limit: 255
    t.string "line_4", limit: 255
    t.index ["user_id"], name: "index_award_labels_on_user_id"
  end

  create_table "boundary_scores", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.integer "judge_id"
    t.integer "number_of_people"
    t.integer "major_dismount"
    t.integer "minor_dismount"
    t.integer "major_boundary"
    t.integer "minor_boundary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competitor_id"], name: "index_boundary_scores_competitor_id"
    t.index ["judge_id", "competitor_id"], name: "index_boundary_scores_on_judge_id_and_competitor_id", unique: true
    t.index ["judge_id"], name: "index_boundary_scores_judge_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "info_url", limit: 255
    t.integer "info_page_id"
  end

  create_table "category_translations", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "locale", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.index ["category_id"], name: "index_category_translations_on_category_id"
    t.index ["locale"], name: "index_category_translations_on_locale"
  end

  create_table "combined_competition_entries", id: :serial, force: :cascade do |t|
    t.integer "combined_competition_id"
    t.string "abbreviation", limit: 255
    t.boolean "tie_breaker", default: false, null: false
    t.integer "points_1"
    t.integer "points_2"
    t.integer "points_3"
    t.integer "points_4"
    t.integer "points_5"
    t.integer "points_6"
    t.integer "points_7"
    t.integer "points_8"
    t.integer "points_9"
    t.integer "points_10"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "competition_id"
    t.integer "base_points"
    t.integer "distance"
  end

  create_table "combined_competitions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "use_age_group_places", default: false, null: false
    t.boolean "tie_break_by_firsts", default: true, null: false
    t.string "calculation_mode", null: false
    t.index ["name"], name: "index_combined_competitions_on_name", unique: true
  end

  create_table "competition_results", id: :serial, force: :cascade do |t|
    t.integer "competition_id"
    t.string "results_file", limit: 255
    t.boolean "system_managed", default: false, null: false
    t.boolean "published", default: false, null: false
    t.datetime "published_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
  end

  create_table "competition_sources", id: :serial, force: :cascade do |t|
    t.integer "target_competition_id"
    t.integer "event_category_id"
    t.integer "competition_id"
    t.string "gender_filter", limit: 255, default: "Both", null: false
    t.integer "max_place"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "min_age"
    t.integer "max_age"
    t.index ["competition_id"], name: "index_competition_sources_competition_id"
    t.index ["event_category_id"], name: "index_competition_sources_event_category_id"
    t.index ["target_competition_id"], name: "index_competition_sources_target_competition_id"
  end

  create_table "competition_wheel_sizes", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.integer "event_id"
    t.integer "wheel_size_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["registrant_id", "event_id"], name: "index_competition_wheel_sizes_on_registrant_id_and_event_id", unique: true
    t.index ["registrant_id", "event_id"], name: "index_competition_wheel_sizes_registrant_id_event_id"
  end

  create_table "competitions", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "age_group_type_id"
    t.boolean "has_experts", default: false, null: false
    t.string "scoring_class", limit: 255
    t.string "start_data_type", limit: 255
    t.string "end_data_type", limit: 255
    t.boolean "uses_lane_assignments", default: false, null: false
    t.datetime "scheduled_completion_at"
    t.boolean "awarded", default: false, null: false
    t.string "award_title_name", limit: 255
    t.string "award_subtitle_name", limit: 255
    t.string "num_members_per_competitor", limit: 255
    t.boolean "automatic_competitor_creation", default: false, null: false
    t.integer "combined_competition_id"
    t.boolean "order_finalized", default: false, null: false
    t.integer "penalty_seconds"
    t.datetime "locked_at"
    t.datetime "published_at"
    t.boolean "sign_in_list_enabled", default: false, null: false
    t.string "time_entry_columns", default: "minutes_seconds_thousands"
    t.boolean "import_results_into_other_competition", default: false, null: false
    t.integer "base_age_group_type_id"
    t.boolean "score_ineligible_competitors", default: false, null: false
    t.index ["base_age_group_type_id"], name: "index_competitions_on_base_age_group_type_id"
    t.index ["combined_competition_id"], name: "index_competitions_on_combined_competition_id", unique: true
    t.index ["event_id"], name: "index_competitions_event_id"
  end

  create_table "competitors", id: :serial, force: :cascade do |t|
    t.integer "competition_id"
    t.integer "position"
    t.string "custom_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status", default: 0
    t.integer "lowest_member_bib_number"
    t.boolean "geared", default: false, null: false
    t.integer "riding_wheel_size"
    t.string "notes", limit: 255
    t.integer "wave"
    t.integer "riding_crank_size"
    t.datetime "withdrawn_at"
    t.integer "tier_number", default: 1, null: false
    t.string "tier_description"
    t.integer "age_group_entry_id"
    t.index ["competition_id", "age_group_entry_id"], name: "index_competitors_on_competition_id_and_age_group_entry_id"
    t.index ["competition_id"], name: "index_competitors_event_category_id"
  end

  create_table "contact_details", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.string "zip", limit: 255
    t.string "country_residence", limit: 255
    t.string "country_representing", limit: 255
    t.string "phone", limit: 255
    t.string "mobile", limit: 255
    t.string "email", limit: 255
    t.string "club", limit: 255
    t.string "club_contact", limit: 255
    t.string "organization_member_number", limit: 255
    t.string "emergency_name", limit: 255
    t.string "emergency_relationship", limit: 255
    t.boolean "emergency_attending", default: false, null: false
    t.string "emergency_primary_phone", limit: 255
    t.string "emergency_other_phone", limit: 255
    t.string "responsible_adult_name", limit: 255
    t.string "responsible_adult_phone", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "organization_membership_manually_confirmed", default: false, null: false
    t.string "birthplace", limit: 255
    t.string "italian_fiscal_code", limit: 255
    t.boolean "organization_membership_system_confirmed", default: false, null: false
    t.string "organization_membership_system_status"
    t.index ["registrant_id"], name: "index_contact_details_on_registrant_id", unique: true
    t.index ["registrant_id"], name: "index_contact_details_registrant_id"
  end

  create_table "coupon_code_expense_items", id: :serial, force: :cascade do |t|
    t.integer "coupon_code_id"
    t.integer "expense_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["coupon_code_id"], name: "index_coupon_code_expense_items_on_coupon_code_id"
    t.index ["expense_item_id"], name: "index_coupon_code_expense_items_on_expense_item_id"
  end

  create_table "coupon_codes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.string "description", limit: 255
    t.integer "max_num_uses", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "inform_emails"
    t.integer "price_cents"
    t.integer "maximum_registrant_age"
    t.index ["code"], name: "index_coupon_codes_on_code", unique: true
  end

  create_table "distance_attempts", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.decimal "distance", precision: 4
    t.boolean "fault", default: false, null: false
    t.integer "judge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competitor_id"], name: "index_distance_attempts_competitor_id"
    t.index ["judge_id"], name: "index_distance_attempts_judge_id"
  end

  create_table "event_categories", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "position"
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "age_range_start", default: 0
    t.integer "age_range_end", default: 100
    t.boolean "warning_on_registration_summary", default: false, null: false
    t.index ["event_id", "name"], name: "index_event_categories_on_event_id_and_name", unique: true
    t.index ["event_id", "position"], name: "index_event_categories_event_id"
  end

  create_table "event_category_translations", id: :serial, force: :cascade do |t|
    t.integer "event_category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["event_category_id"], name: "index_event_category_translations_on_event_category_id"
    t.index ["locale"], name: "index_event_category_translations_on_locale"
  end

  create_table "event_choice_translations", id: :serial, force: :cascade do |t|
    t.integer "event_choice_id", null: false
    t.string "locale", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "label", limit: 255
    t.string "tooltip", limit: 255
    t.index ["event_choice_id"], name: "index_event_choice_translations_on_event_choice_id"
    t.index ["locale"], name: "index_event_choice_translations_on_locale"
  end

  create_table "event_choices", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.string "cell_type", limit: 255
    t.string "multiple_values", limit: 255
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "optional", default: false, null: false
    t.integer "optional_if_event_choice_id"
    t.integer "required_if_event_choice_id"
    t.index ["event_id", "position"], name: "index_event_choices_on_event_id_and_position"
  end

  create_table "event_configuration_translations", id: :serial, force: :cascade do |t|
    t.integer "event_configuration_id", null: false
    t.string "locale", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "short_name", limit: 255
    t.string "long_name", limit: 255
    t.string "location", limit: 255
    t.string "dates_description", limit: 255
    t.text "competitor_benefits"
    t.text "noncompetitor_benefits"
    t.text "spectator_benefits"
    t.text "offline_payment_description"
    t.index ["event_configuration_id"], name: "index_8da8125feacb8971b8fc26e0e628b77608288047"
    t.index ["locale"], name: "index_event_configuration_translations_on_locale"
  end

  create_table "event_configurations", id: :serial, force: :cascade do |t|
    t.string "event_url", limit: 255
    t.date "start_date"
    t.string "contact_email", limit: 255
    t.date "artistic_closed_date"
    t.date "standard_skill_closed_date"
    t.date "event_sign_up_closed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "test_mode", default: false, null: false
    t.string "comp_noncomp_url", limit: 255
    t.boolean "standard_skill", default: false, null: false
    t.boolean "usa", default: false, null: false
    t.boolean "iuf", default: false, null: false
    t.string "currency_code", limit: 255
    t.string "rulebook_url", limit: 255
    t.string "style_name", limit: 255
    t.text "custom_waiver_text"
    t.date "music_submission_end_date"
    t.boolean "artistic_score_elimination_mode_naucc", default: false, null: false
    t.string "logo_file", limit: 255
    t.integer "max_award_place", default: 5
    t.boolean "display_confirmed_events", default: false, null: false
    t.boolean "spectators", default: false, null: false
    t.string "paypal_account", limit: 255
    t.string "waiver", limit: 255, default: "none"
    t.integer "validations_applied"
    t.boolean "italian_requirements", default: false, null: false
    t.string "rules_file_name", limit: 255
    t.boolean "accept_rules", default: false, null: false
    t.string "paypal_mode", limit: 255, default: "disabled"
    t.boolean "offline_payment", default: false, null: false
    t.string "enabled_locales", null: false
    t.integer "comp_noncomp_page_id"
    t.boolean "under_construction", default: true, null: false
    t.boolean "noncompetitors", default: true, null: false
    t.string "volunteer_option", default: "generic", null: false
    t.date "age_calculation_base_date"
    t.string "organization_membership_type"
    t.boolean "request_address", default: true, null: false
    t.boolean "request_emergency_contact", default: true, null: false
    t.boolean "request_responsible_adult", default: true, null: false
    t.boolean "registrants_should_specify_default_wheel_size", default: true, null: false
    t.datetime "add_event_end_date"
    t.integer "max_registrants", default: 0, null: false
    t.string "representation_type", default: "country", null: false
  end

  create_table "event_translations", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["event_id"], name: "index_event_translations_on_event_id"
    t.index ["locale"], name: "index_event_translations_on_locale"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.integer "category_id"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.boolean "visible", default: true, null: false
    t.boolean "accepts_music_uploads", default: false, null: false
    t.boolean "artistic", default: false, null: false
    t.boolean "accepts_wheel_size_override", default: false, null: false
    t.integer "event_categories_count", default: 0, null: false
    t.integer "event_choices_count", default: 0, null: false
    t.string "best_time_format", default: "none", null: false
    t.boolean "standard_skill", default: false, null: false
    t.index ["accepts_wheel_size_override"], name: "index_events_on_accepts_wheel_size_override"
    t.index ["category_id"], name: "index_events_category_id"
  end

  create_table "expense_group_free_options", id: :serial, force: :cascade do |t|
    t.integer "expense_group_id", null: false
    t.string "registrant_type", null: false
    t.string "free_option", null: false
    t.integer "min_age"
    t.integer "max_age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_group_id", "registrant_type"], name: "free_options_group_reg_type", unique: true
    t.index ["expense_group_id"], name: "index_expense_group_free_options_on_expense_group_id"
  end

  create_table "expense_group_translations", id: :serial, force: :cascade do |t|
    t.integer "expense_group_id", null: false
    t.string "locale", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "group_name", limit: 255
    t.index ["expense_group_id"], name: "index_expense_group_translations_on_expense_group_id"
    t.index ["locale"], name: "index_expense_group_translations_on_locale"
  end

  create_table "expense_groups", id: :serial, force: :cascade do |t|
    t.boolean "visible", default: true, null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "info_url", limit: 255
    t.boolean "competitor_required", default: false, null: false
    t.boolean "noncompetitor_required", default: false, null: false
    t.boolean "registration_items", default: false, null: false
    t.integer "info_page_id"
    t.boolean "system_managed", default: false, null: false
  end

  create_table "expense_item_translations", id: :serial, force: :cascade do |t|
    t.integer "expense_item_id", null: false
    t.string "locale", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.string "details_label", limit: 255
    t.index ["expense_item_id"], name: "index_expense_item_translations_on_expense_item_id"
    t.index ["locale"], name: "index_expense_item_translations_on_locale"
  end

  create_table "expense_items", id: :serial, force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "expense_group_id"
    t.boolean "has_details", default: false, null: false
    t.integer "maximum_available"
    t.boolean "has_custom_cost", default: false, null: false
    t.integer "maximum_per_registrant", default: 0
    t.integer "cost_cents"
    t.integer "tax_cents", default: 0, null: false
    t.integer "cost_element_id"
    t.string "cost_element_type"
    t.index ["cost_element_type", "cost_element_id"], name: "index_expense_items_on_cost_element_type_and_cost_element_id", unique: true
    t.index ["expense_group_id"], name: "index_expense_items_expense_group_id"
  end

  create_table "external_results", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.string "details", limit: 255
    t.decimal "points", precision: 6, scale: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "entered_by_id", null: false
    t.datetime "entered_at", null: false
    t.string "status", null: false
    t.boolean "preliminary", null: false
    t.index ["competitor_id"], name: "index_external_results_on_competitor_id", unique: true
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "entered_email"
    t.text "message"
    t.string "status", default: "new", null: false
    t.datetime "resolved_at"
    t.integer "resolved_by_id"
    t.text "resolution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "heat_lane_judge_notes", id: :serial, force: :cascade do |t|
    t.integer "competition_id", null: false
    t.integer "heat", null: false
    t.integer "lane", null: false
    t.string "status", null: false
    t.string "comments"
    t.datetime "entered_at", null: false
    t.integer "entered_by_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competition_id"], name: "index_heat_lane_judge_notes_on_competition_id"
  end

  create_table "heat_lane_results", id: :serial, force: :cascade do |t|
    t.integer "competition_id", null: false
    t.integer "heat", null: false
    t.integer "lane", null: false
    t.string "status", null: false
    t.integer "minutes", null: false
    t.integer "seconds", null: false
    t.integer "thousands", null: false
    t.string "raw_data"
    t.datetime "entered_at", null: false
    t.integer "entered_by_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_results", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "raw_data", limit: 255
    t.integer "bib_number"
    t.integer "minutes"
    t.integer "seconds"
    t.integer "thousands"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "competition_id"
    t.decimal "points", precision: 6, scale: 3
    t.string "details", limit: 255
    t.boolean "is_start_time", default: false, null: false
    t.integer "number_of_laps"
    t.string "status", limit: 255
    t.text "comments"
    t.string "comments_by", limit: 255
    t.integer "heat"
    t.integer "lane"
    t.integer "number_of_penalties"
    t.index ["user_id"], name: "index_import_results_on_user_id"
    t.index ["user_id"], name: "index_imported_results_user_id"
  end

  create_table "judge_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "val_1_description", limit: 255
    t.string "val_2_description", limit: 255
    t.string "val_3_description", limit: 255
    t.string "val_4_description", limit: 255
    t.integer "val_1_max"
    t.integer "val_2_max"
    t.integer "val_3_max"
    t.integer "val_4_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "event_class", limit: 255
    t.boolean "boundary_calculation_enabled", default: false, null: false
    t.string "val_5_description"
    t.integer "val_5_max"
    t.index ["name", "event_class"], name: "index_judge_types_on_name_and_event_class", unique: true
  end

  create_table "judges", id: :serial, force: :cascade do |t|
    t.integer "competition_id"
    t.integer "judge_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "active", null: false
    t.index ["competition_id"], name: "index_judges_event_category_id"
    t.index ["judge_type_id", "competition_id", "user_id"], name: "index_judges_on_judge_type_id_and_competition_id_and_user_id", unique: true
    t.index ["judge_type_id"], name: "index_judges_judge_type_id"
    t.index ["user_id"], name: "index_judges_user_id"
  end

  create_table "lane_assignments", id: :serial, force: :cascade do |t|
    t.integer "competition_id"
    t.integer "heat"
    t.integer "lane"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "competitor_id"
    t.index ["competition_id", "heat", "lane"], name: "index_lane_assignments_on_competition_id_and_heat_and_lane", unique: true
    t.index ["competition_id"], name: "index_lane_assignments_on_competition_id"
  end

  create_table "mass_emails", id: :serial, force: :cascade do |t|
    t.integer "sent_by_id", null: false
    t.datetime "sent_at"
    t.string "subject"
    t.text "body"
    t.text "email_addresses", array: true
    t.string "email_addresses_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_addresses"], name: "index_mass_emails_on_email_addresses", using: :gin
  end

  create_table "members", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.integer "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "dropped_from_registration", default: false, null: false
    t.boolean "alternate", default: false, null: false
    t.index ["competitor_id"], name: "index_members_competitor_id"
    t.index ["registrant_id"], name: "index_members_registrant_id"
  end

  create_table "page_images", id: :serial, force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "name", null: false
    t.string "image", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_translations", id: :serial, force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "body"
    t.index ["locale"], name: "index_page_translations_on_locale"
    t.index ["page_id"], name: "index_page_translations_on_page_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.integer "parent_page_id"
    t.index ["parent_page_id", "position"], name: "index_pages_on_parent_page_id_and_position"
    t.index ["position"], name: "index_pages_on_position"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "payment_detail_coupon_codes", id: :serial, force: :cascade do |t|
    t.integer "payment_detail_id"
    t.integer "coupon_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["coupon_code_id"], name: "index_payment_detail_coupon_codes_on_coupon_code_id"
    t.index ["payment_detail_id"], name: "index_payment_detail_coupon_codes_on_payment_detail_id", unique: true
  end

  create_table "payment_details", id: :serial, force: :cascade do |t|
    t.integer "payment_id"
    t.integer "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "line_item_id"
    t.string "details", limit: 255
    t.boolean "free", default: false, null: false
    t.boolean "refunded", default: false, null: false
    t.integer "amount_cents"
    t.string "line_item_type"
    t.index ["line_item_id", "line_item_type"], name: "index_payment_details_on_line_item_id_and_line_item_type"
    t.index ["payment_id"], name: "index_payment_details_payment_id"
    t.index ["registrant_id"], name: "index_payment_details_registrant_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "completed", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.string "transaction_id", limit: 255
    t.datetime "completed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "payment_date", limit: 255
    t.string "note", limit: 255
    t.string "invoice_id", limit: 255
    t.boolean "offline_pending", default: false, null: false
    t.datetime "offline_pending_date"
    t.index ["user_id"], name: "index_payments_user_id"
  end

  create_table "published_age_group_entries", id: :serial, force: :cascade do |t|
    t.integer "competition_id"
    t.integer "age_group_entry_id"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competition_id"], name: "index_published_age_group_entries_on_competition_id"
  end

  create_table "rails_admin_histories", id: :serial, force: :cascade do |t|
    t.text "message"
    t.string "username", limit: 255
    t.integer "item"
    t.string "table", limit: 255
    t.integer "month", limit: 2
    t.bigint "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item", "table", "month", "year"], name: "index_rails_admin_histories"
  end

  create_table "refund_details", id: :serial, force: :cascade do |t|
    t.integer "refund_id"
    t.integer "payment_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_detail_id"], name: "index_refund_details_on_payment_detail_id", unique: true
    t.index ["refund_id"], name: "index_refund_details_on_refund_id"
  end

  create_table "refunds", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "refund_date"
    t.string "note", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "percentage", default: 100
    t.index ["user_id"], name: "index_refunds_on_user_id"
  end

  create_table "registrant_best_times", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "registrant_id", null: false
    t.string "source_location", null: false
    t.integer "value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id", "registrant_id"], name: "index_registrant_best_times_on_event_id_and_registrant_id", unique: true
    t.index ["registrant_id"], name: "index_registrant_best_times_on_registrant_id"
  end

  create_table "registrant_choices", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.integer "event_choice_id"
    t.string "value", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_choice_id"], name: "index_registrant_choices_event_choice_id"
    t.index ["registrant_id", "event_choice_id"], name: "index_registrant_choices_on_registrant_id_and_event_choice_id", unique: true
    t.index ["registrant_id"], name: "index_registrant_choices_registrant_id"
  end

  create_table "registrant_event_sign_ups", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.boolean "signed_up", default: false, null: false
    t.integer "event_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.index ["event_category_id"], name: "index_registrant_event_sign_ups_event_category_id"
    t.index ["event_id"], name: "index_registrant_event_sign_ups_event_id"
    t.index ["registrant_id", "event_id"], name: "index_registrant_event_sign_ups_on_registrant_id_and_event_id", unique: true
    t.index ["registrant_id"], name: "index_registrant_event_sign_ups_registrant_id"
  end

  create_table "registrant_expense_items", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.integer "line_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "details", limit: 255
    t.boolean "free", default: false, null: false
    t.boolean "system_managed", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.integer "custom_cost_cents"
    t.string "line_item_type"
    t.index ["line_item_id", "line_item_type"], name: "registrant_expense_items_line_item"
    t.index ["registrant_id"], name: "index_registrant_expense_items_registrant_id"
  end

  create_table "registrant_group_leaders", id: :serial, force: :cascade do |t|
    t.integer "registrant_group_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registrant_group_id", "user_id"], name: "registrant_group_leaders_uniq", unique: true
    t.index ["registrant_group_id"], name: "index_registrant_group_leaders_on_registrant_group_id"
    t.index ["user_id"], name: "index_registrant_group_leaders_on_user_id"
  end

  create_table "registrant_group_members", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.integer "registrant_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "additional_details_type"
    t.integer "additional_details_id"
    t.index ["registrant_group_id"], name: "index_registrant_group_members_on_registrant_group_id"
    t.index ["registrant_id", "registrant_group_id"], name: "reg_group_reg_group", unique: true
    t.index ["registrant_id"], name: "index_registrant_group_members_on_registrant_id"
  end

  create_table "registrant_group_types", id: :serial, force: :cascade do |t|
    t.string "source_element_type", null: false
    t.integer "source_element_id", null: false
    t.string "notes"
    t.integer "max_members_per_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registrant_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "registrant_group_type_id"
    t.index ["registrant_group_type_id"], name: "index_registrant_groups_on_registrant_group_type_id"
  end

  create_table "registrants", id: :serial, force: :cascade do |t|
    t.string "first_name", limit: 255
    t.string "middle_initial", limit: 255
    t.string "last_name", limit: 255
    t.date "birthday"
    t.string "gender", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.boolean "deleted", default: false, null: false
    t.integer "bib_number", null: false
    t.integer "wheel_size_id"
    t.integer "age"
    t.boolean "ineligible", default: false, null: false
    t.boolean "volunteer", default: false, null: false
    t.string "online_waiver_signature", limit: 255
    t.string "access_code", limit: 255
    t.string "sorted_last_name", limit: 255
    t.string "status", limit: 255, default: "active", null: false
    t.string "registrant_type", limit: 255, default: "competitor"
    t.boolean "rules_accepted", default: false, null: false
    t.boolean "online_waiver_acceptance", default: false, null: false
    t.boolean "paid", default: false, null: false
    t.index ["bib_number"], name: "index_registrants_on_bib_number", unique: true
    t.index ["deleted"], name: "index_registrants_deleted"
    t.index ["registrant_type"], name: "index_registrants_on_registrant_type"
    t.index ["user_id"], name: "index_registrants_on_user_id"
  end

  create_table "registration_cost_entries", id: :serial, force: :cascade do |t|
    t.integer "registration_cost_id", null: false
    t.integer "expense_item_id", null: false
    t.integer "min_age"
    t.integer "max_age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_cost_id"], name: "index_registration_cost_entries_on_registration_cost_id"
  end

  create_table "registration_cost_translations", id: :serial, force: :cascade do |t|
    t.integer "registration_cost_id", null: false
    t.string "locale", null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["locale"], name: "index_registration_cost_translations_on_locale"
    t.index ["registration_cost_id"], name: "index_registration_cost_translations_on_registration_cost_id"
  end

  create_table "registration_costs", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.string "registrant_type", null: false
    t.boolean "onsite", default: false, null: false
    t.boolean "current_period", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_period"], name: "index_registration_costs_on_current_period"
    t.index ["registrant_type", "current_period"], name: "index_registration_costs_on_registrant_type_and_current_period"
  end

  create_table "registration_period_translations", id: :serial, force: :cascade do |t|
    t.integer "registration_period_id", null: false
    t.string "locale", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.index ["locale"], name: "index_registration_period_translations_on_locale"
    t.index ["registration_period_id"], name: "index_43f042772e959a61bb6b1fedb770048039229050"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.string "report_type", null: false
    t.string "url"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.string "result_type", limit: 255
    t.integer "result_subtype"
    t.integer "place"
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competitor_id", "result_type"], name: "index_results_on_competitor_id_and_result_type", unique: true
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "resource_id"
    t.string "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "scores", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.decimal "val_1", precision: 5, scale: 3
    t.decimal "val_2", precision: 5, scale: 3
    t.decimal "val_3", precision: 5, scale: 3
    t.decimal "val_4", precision: 5, scale: 3
    t.text "notes"
    t.integer "judge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "val_5", precision: 5, scale: 3
    t.index ["competitor_id", "judge_id"], name: "index_scores_on_competitor_id_and_judge_id", unique: true
    t.index ["competitor_id"], name: "index_scores_competitor_id"
    t.index ["judge_id"], name: "index_scores_judge_id"
  end

  create_table "songs", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.string "description", limit: 255
    t.string "song_file_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.integer "user_id"
    t.integer "competitor_id"
    t.index ["competitor_id"], name: "index_songs_on_competitor_id", unique: true
    t.index ["registrant_id"], name: "index_songs_registrant_id"
    t.index ["user_id", "registrant_id", "event_id"], name: "index_songs_on_user_id_and_registrant_id_and_event_id", unique: true
  end

  create_table "standard_skill_entries", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "letter", limit: 255
    t.decimal "points", precision: 6, scale: 2
    t.string "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "friendly_description"
    t.integer "additional_description_id"
    t.string "skill_speed"
    t.integer "skill_before_id"
    t.integer "skill_after_id"
    t.index ["letter", "number"], name: "index_standard_skill_entries_on_letter_and_number", unique: true
  end

  create_table "standard_skill_entry_additional_descriptions", id: :serial, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_skill_entry_transitions", id: :serial, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_skill_routine_entries", id: :serial, force: :cascade do |t|
    t.integer "standard_skill_routine_id"
    t.integer "standard_skill_entry_id"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "standard_skill_routines", id: :serial, force: :cascade do |t|
    t.integer "registrant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["registrant_id"], name: "index_standard_skill_routines_on_registrant_id", unique: true
  end

  create_table "standard_skill_score_entries", id: :serial, force: :cascade do |t|
    t.integer "standard_skill_score_id", null: false
    t.integer "standard_skill_routine_entry_id", null: false
    t.integer "difficulty_devaluation_percent", default: 0, null: false
    t.integer "wave", default: 0, null: false
    t.integer "line", default: 0, null: false
    t.integer "cross", default: 0, null: false
    t.integer "circle", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["standard_skill_score_id", "standard_skill_routine_entry_id"], name: "standard_skill_entries_unique", unique: true
  end

  create_table "standard_skill_scores", id: :serial, force: :cascade do |t|
    t.integer "competitor_id", null: false
    t.integer "judge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_standard_skill_scores_on_competitor_id"
    t.index ["judge_id", "competitor_id"], name: "index_standard_skill_scores_on_judge_id_and_competitor_id", unique: true
  end

  create_table "tenant_aliases", id: :serial, force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "website_alias", limit: 255, null: false
    t.boolean "primary_domain", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "verified", default: false, null: false
    t.index ["tenant_id", "primary_domain"], name: "index_tenant_aliases_on_tenant_id_and_primary_domain"
    t.index ["website_alias"], name: "index_tenant_aliases_on_website_alias"
  end

  create_table "tenants", id: :serial, force: :cascade do |t|
    t.string "subdomain", limit: 255
    t.string "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "admin_upgrade_code", limit: 255
    t.index ["subdomain"], name: "index_tenants_on_subdomain"
  end

  create_table "tie_break_adjustments", id: :serial, force: :cascade do |t|
    t.integer "tie_break_place"
    t.integer "judge_id"
    t.integer "competitor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competitor_id", "judge_id"], name: "index_tie_break_adjustments_on_competitor_id_and_judge_id", unique: true
    t.index ["competitor_id"], name: "index_tie_break_adjustments_competitor_id"
    t.index ["competitor_id"], name: "index_tie_break_adjustments_on_competitor_id", unique: true
    t.index ["judge_id"], name: "index_tie_break_adjustments_judge_id"
  end

  create_table "time_results", id: :serial, force: :cascade do |t|
    t.integer "competitor_id"
    t.integer "minutes"
    t.integer "seconds"
    t.integer "thousands"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_start_time", default: false, null: false
    t.integer "number_of_laps"
    t.string "status", limit: 255, null: false
    t.text "comments"
    t.string "comments_by", limit: 255
    t.integer "number_of_penalties"
    t.datetime "entered_at", null: false
    t.integer "entered_by_id", null: false
    t.boolean "preliminary"
    t.integer "heat_lane_result_id"
    t.string "status_description"
    t.index ["competitor_id"], name: "index_time_results_on_competitor_id"
    t.index ["heat_lane_result_id"], name: "index_time_results_on_heat_lane_result_id", unique: true
  end

  create_table "tolk_locales", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_tolk_locales_on_name", unique: true
  end

  create_table "tolk_phrases", id: :serial, force: :cascade do |t|
    t.text "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", id: :serial, force: :cascade do |t|
    t.integer "phrase_id"
    t.integer "locale_id"
    t.text "text"
    t.text "previous_text"
    t.boolean "primary_updated", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true
  end

  create_table "two_attempt_entries", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
    t.integer "bib_number"
    t.integer "minutes_1"
    t.integer "minutes_2"
    t.integer "seconds_1"
    t.string "status_1", limit: 255, default: "active"
    t.integer "seconds_2"
    t.integer "thousands_1"
    t.integer "thousands_2"
    t.string "status_2", limit: 255, default: "active"
    t.boolean "is_start_time", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["competition_id", "is_start_time", "id"], name: "index_two_attempt_entries_ids"
  end

  create_table "uploaded_files", id: :serial, force: :cascade do |t|
    t.integer "competition_id", null: false
    t.integer "user_id", null: false
    t.string "original_file", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_uploaded_files_on_competition_id"
    t.index ["user_id"], name: "index_uploaded_files_on_user_id"
  end

  create_table "user_conventions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "legacy_user_id"
    t.string "subdomain", null: false
    t.string "legacy_encrypted_password", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.boolean "guest", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "registrant_id"
    t.integer "user_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "volunteer_choices", id: :serial, force: :cascade do |t|
    t.integer "registrant_id", null: false
    t.integer "volunteer_opportunity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["registrant_id", "volunteer_opportunity_id"], name: "volunteer_choices_reg_vol_opt_unique", unique: true
    t.index ["registrant_id"], name: "index_volunteer_choices_on_registrant_id"
    t.index ["volunteer_opportunity_id"], name: "index_volunteer_choices_on_volunteer_opportunity_id"
  end

  create_table "volunteer_opportunities", id: :serial, force: :cascade do |t|
    t.string "description", limit: 255, null: false
    t.integer "position"
    t.text "inform_emails"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["description"], name: "index_volunteer_opportunities_on_description", unique: true
    t.index ["position"], name: "index_volunteer_opportunities_on_position"
  end

  create_table "wave_times", id: :serial, force: :cascade do |t|
    t.integer "competition_id"
    t.integer "wave"
    t.integer "minutes"
    t.integer "seconds"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "scheduled_time", limit: 255
    t.index ["competition_id", "wave"], name: "index_wave_times_on_competition_id_and_wave", unique: true
  end

  create_table "wheel_sizes", id: :serial, force: :cascade do |t|
    t.integer "position"
    t.string "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
