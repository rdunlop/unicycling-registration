class AddStandardSkillDataEntry < ActiveRecord::Migration
  def change
    create_table :standard_skill_entries do |t|
      t.integer  :number
      t.string   :letter
      t.decimal  :points
      t.string   :description

      t.timestamps
    end

    create_table :standard_skill_routines do |t|
      t.integer :registrant_id
      t.timestamps
    end

    create_table :standard_skill_routine_entries do |t|
      t.integer  :standard_skill_routine_id
      t.integer  :standard_skill_entry_id
      t.integer  :position
      t.timestamps
    end
  end
end
