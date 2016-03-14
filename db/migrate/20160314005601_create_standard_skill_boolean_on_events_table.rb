class CreateStandardSkillBooleanOnEventsTable < ActiveRecord::Migration
  def change
    add_column :events, :standard_skill, :boolean, default: false, null: false
  end
end
