class AddMissingUniquenessIndexes < ActiveRecord::Migration
  def up
    add_index :additional_registrant_accesses, [:registrant_id, :user_id], unique: true, name: "ada_reg_user"

    add_index :age_group_entries, [:age_group_type_id, :short_description], unique: true, name: "age_type_desc"

    add_index :age_group_types, :name, unique: true

    add_index :boundary_scores, [:judge_id, :competitor_id], unique: true

    add_index :combined_competitions, :name, unique: true

    add_index :competition_wheel_sizes, [:registrant_id, :event_id], unique: true

    add_index :event_categories, [:event_id, :name], unique: true
    add_index :event_categories, [:event_id, :position], unique: true

    add_index :event_choices, :export_name, unique: true
    remove_index :event_choices, name: :index_event_choices_event_id
    add_index :event_choices, [:event_id, :position], unique: true

    add_index :heat_times, [:competition_id, :heat], unique: true

    add_index :judges, [:judge_type_id, :competition_id, :user_id], unique: true

    add_index :judge_types, :name, unique: true

    add_index :lane_assignments, [:competition_id, :heat, :lane], unique: true

    add_index :registrant_choices, [:registrant_id, :event_choice_id], unique: true

    add_index :registrant_event_sign_ups, [:registrant_id, :event_id], unique: true

    add_index :registrant_group_members, [:registrant_id, :registrant_group_id], unique: true, name: "reg_group_reg_group"

    add_index :results, [:competitor_id, :result_type], unique: true

    add_index :scores, [:competitor_id, :judge_id], unique: true

    add_index :songs, [:user_id, :registrant_id, :event_id], unique: true

    add_index :standard_difficulty_scores, [:judge_id, :standard_skill_routine_entry_id, :competitor_id], unique: true, name: "standard_diff_judge_routine_comp"

    add_index :standard_execution_scores, [:judge_id, :standard_skill_routine_entry_id, :competitor_id], unique: true,name: "standard_exec_judge_routine_comp"

    add_index :standard_skill_entries, [:letter, :number], unique: true

    add_index :standard_skill_routines, :registrant_id, unique: true

    add_index :tie_break_adjustments, [:competitor_id, :judge_id], unique: true

    # has_one

    add_index :competitions, :combined_competition_id, unique: true

    add_index :tie_break_adjustments, :competitor_id, unique: true

    remove_index :refund_details, :payment_detail_id
    add_index :refund_details, :payment_detail_id, unique: true

    add_index :contact_details, :registrant_id, unique: true
  end

  def down
    remove_index :additional_registrant_accesses, name: "ada_reg_user"

    remove_index :age_group_entries, name: "age_type_desc"

    remove_index :age_group_types, :name

    remove_index :boundary_scores, [:judge_id, :competitor_id]

    remove_index :combined_competitions, :name

    remove_index :competition_wheel_sizes, [:registrant_id, :event_id]

    remove_index :event_categories, [:event_id, :name]
    remove_index :event_categories, [:event_id, :position]

    remove_index :event_choices, :export_name
    remove_index :event_choices, [:event_id, :position]
    add_index :event_choices, [:event_id, :position], name: :index_event_choices_event_id

    remove_index :heat_times, [:competition_id, :heat]

    remove_index :judges, [:judge_type_id, :competition_id, :user_id]

    remove_index :judge_types, :name

    remove_index :lane_assignments, [:competition_id, :heat, :lane]

    remove_index :registrant_choices, [:registrant_id, :event_choice_id]

    remove_index :registrant_event_sign_ups, [:registrant_id, :event_id]

    remove_index :registrant_group_members, name: "reg_group_reg_group"

    remove_index :results, [:competitor_id, :result_type]

    remove_index :scores, [:competitor_id, :judge_id]

    remove_index :songs, [:user_id, :registrant_id, :event_id]

    remove_index :standard_difficulty_scores, name: "standard_diff_judge_routine_comp"

    remove_index :standard_execution_scores, name: "standard_exec_judge_routine_comp"

    remove_index :standard_skill_entries, [:letter, :number]

    remove_index :standard_skill_routines, :registrant_id

    remove_index :tie_break_adjustments, [:competitor_id, :judge_id]

    # has_one

    remove_index :competitions, :combined_competition_id

    remove_index :tie_break_adjustments, :competitor_id

    remove_index :refund_details, :payment_detail_id
    add_index :refund_details, :payment_detail_id

    remove_index :contact_details, :registrant_id
  end
end
