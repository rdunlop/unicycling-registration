class CreateStandardSkillBooleanOnEventsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :standard_skill, :boolean, default: false, null: false
  end
end
