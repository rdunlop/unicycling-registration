class AddScores < ActiveRecord::Migration
  def change
    create_table :boundary_scores do |t|
      t.integer  :competitor_id
      t.integer  :judge_id
      t.integer  :number_of_people
      t.integer  :major_dismount
      t.integer  :minor_dismount
      t.integer  :major_boundary
      t.integer  :minor_boundary
      t.timestamps
    end

    create_table :distance_attempts do |t|
      t.integer  :competitor_id
      t.decimal  :distance,      :precision => 4, :scale => 0
      t.boolean  :fault
      t.integer  :judge_id
      t.timestamps
    end

    create_table :scores do |t|
      t.integer  :competitor_id
      t.decimal  :val_1,          :precision => 5, :scale => 3
      t.decimal  :val_2,          :precision => 5, :scale => 3
      t.decimal  :val_3,          :precision => 5, :scale => 3
      t.decimal  :val_4,          :precision => 5, :scale => 3
      t.text     :notes
      t.integer  :judge_id
      t.timestamps
    end

    create_table :standard_difficulty_scores do |t|
      t.integer  :competitor_id
      t.integer  :standard_skill_routine_entry_id
      t.integer  :judge_id
      t.integer  :devaluation
      t.timestamps
    end

    create_table :standard_execution_scores do |t|
      t.integer  :competitor_id
      t.integer  :standard_skill_routine_entry_id
      t.integer  :judge_id
      t.integer  :wave
      t.integer  :line
      t.integer  :cross
      t.integer  :circle
      t.timestamps
    end

    create_table "street_scores", :force => true do |t|
      t.integer  :competitor_id
      t.integer  :judge_id
      t.decimal  :val_1,          :precision => 5, :scale => 3
      t.timestamps
    end
  end
end
