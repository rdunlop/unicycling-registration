class AddAdditionalStandardSkillDataTables < ActiveRecord::Migration
  def up
    create_table :standard_skill_entry_transitions do |t|
      t.string :description
      t.timestamps null: false
    end

    create_table :standard_skill_entry_additional_descriptions do |t|
      t.string :description
      t.timestamps null: false
    end

    add_column :standard_skill_entries, :friendly_description, :text
    add_column :standard_skill_entries, :additional_description_id, :integer
    add_column :standard_skill_entries, :skill_speed, :string
    add_column :standard_skill_entries, :skill_before_id, :integer
    add_column :standard_skill_entries, :skill_after_id, :integer
  end

  def down
    drop_table :standard_skill_entry_transitions
    drop_table :standard_skill_entry_additional_descriptions

    remove_column :standard_skill_entries, :friendly_description
    remove_column :standard_skill_entries, :additional_description_id
    remove_column :standard_skill_entries, :skill_speed
    remove_column :standard_skill_entries, :skill_before_id
    remove_column :standard_skill_entries, :skill_after_id
  end
end
