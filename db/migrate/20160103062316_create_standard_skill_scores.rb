class CreateStandardSkillScores < ActiveRecord::Migration
  def up
    create_table :standard_skill_scores do |t|
      t.integer  :competitor_id, null: false
      t.integer  :judge_id, null: false
      t.timestamps null: false
    end

    add_index :standard_skill_scores, [:competitor_id]
    add_index :standard_skill_scores, [:judge_id, :competitor_id]

    create_table :standard_skill_score_entries do |t|
      t.integer :standard_skill_score_id, null: false
      t.integer :standard_skill_routine_entry_id, null: false
      t.integer :difficulty_devaluation_percent, null: false
      t.integer :wave, null: false
      t.integer :line, null: false
      t.integer :cross, null: false
      t.integer :circle, null: false
      t.timestamps null: false
    end

    add_index :standard_skill_score_entries, [:standard_skill_score_id, :standard_skill_routine_entry_id], unique: true, name: "standard_skill_entries_unique"

    drop_table :standard_difficulty_scores
    drop_table :standard_execution_scores
  end

  def down
    drop_table :standard_skill_scores
    drop_table :standard_skill_score_entries

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
  end
end
