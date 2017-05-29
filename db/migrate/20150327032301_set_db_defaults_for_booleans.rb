class SetDbDefaultsForBooleans < ActiveRecord::Migration
  def up
    change_column_default :additional_registrant_accesses, :declined, false
    change_column_default :additional_registrant_accesses, :accepted_readonly, false
    change_column_null :additional_registrant_accesses, :declined, false
    change_column_null :additional_registrant_accesses, :accepted_readwrite, false
    change_column_null :additional_registrant_accesses, :accepted_readonly, false

    change_column_null :combined_competitions, :use_age_group_places, false
    change_column_null :combined_competitions, :percentage_based_calculations, false

    change_column_default :combined_competition_entries, :tie_breaker, false
    change_column_null :combined_competition_entries, :tie_breaker, false

    change_column_null :competitions, :has_experts, false, false
    change_column_null :competitions, :uses_lane_assignments, false, false
    change_column_null :competitions, :published, false, false
    change_column_null :competitions, :awarded, false, false
    change_column_null :competitions, :automatic_competitor_creation, false, false
    change_column_null :competitions, :order_finalized, false, false

    change_column_default :competition_results, :system_managed, false
    change_column_null :competition_results, :system_managed, false, false
    change_column_default :competition_results, :published, false
    change_column_null :competition_results, :published, false, false

    change_column_default :competition_sources, :gender_filter, "Both"
    change_column_null :competition_sources, :gender_filter, false, "Both"

    change_column_null :competitors, :geared, false, false

    change_column_null :contact_details, :usa_confirmed_paid, false, false

    change_column_default :distance_attempts, :fault, false
    change_column_null :distance_attempts, :fault, false, false

    change_column_null :events, :accepts_music_uploads, false, false
    change_column_null :events, :artistic, false, false
    change_column_null :events, :accepts_wheel_size_override, false, false

    change_column_null :event_categories, :warning_on_registration_summary, false, false

    change_column_default :event_choices, :autocomplete, false
    change_column_null :event_choices, :autocomplete, false, false
    change_column_null :event_choices, :optional, false, false

    change_column_default :event_configurations, :test_mode, false
    change_column_null :event_configurations, :test_mode, false, false
    change_column_null :event_configurations, :usa, false, false
    change_column_null :event_configurations, :usa_membership_config, false, false
    change_column_null :event_configurations, :iuf, false, false
    change_column_null :event_configurations, :standard_skill, false, false
    change_column_null :event_configurations, :artistic_score_elimination_mode_naucc, false, true
    change_column_null :event_configurations, :display_confirmed_events, false, false
    change_column_null :event_configurations, :spectators, false, false

    change_column_default :expense_items, :has_details, false
    change_column_null :expense_items, :has_details, false, false
    change_column_default :expense_items, :tax_cents, 0
    change_column_null :expense_items, :tax_cents, false, 0
    change_column_null :expense_items, :has_custom_cost, false, false

    change_column_null :import_results, :is_start_time, false, false

    change_column_default :judge_types, :boundary_calculation_enabled, false
    change_column_null :judge_types, :boundary_calculation_enabled, false, false

    change_column_null :members, :dropped_from_registration, false, false

    change_column_default :payments, :completed, false
    change_column_null :payments, :completed, false, false
    change_column_default :payments, :cancelled, false
    change_column_null :payments, :cancelled, false, false

    change_column_null :payment_details, :free, false, false
    change_column_null :payment_details, :refunded, false, false

    change_column_default :registrants, :deleted, false
    change_column_null :registrants, :deleted, false, false
    change_column_null :registrants, :ineligible, false, false
    change_column_default :registrants, :volunteer, false
    change_column_null :registrants, :volunteer, false, false

    change_column_null :registrant_expense_items, :free, false
    change_column_null :registrant_expense_items, :system_managed, false
    change_column_null :registrant_expense_items, :locked, false

    change_column_default :registration_periods, :onsite, false
    change_column_null :registration_periods, :onsite, false, false
    change_column_null :registration_periods, :current_period, false, false

    change_column_null :time_results, :is_start_time, false, false
    change_column_null :two_attempt_entries, :is_start_time, false, false
    change_column_null :users, :guest, false, false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
