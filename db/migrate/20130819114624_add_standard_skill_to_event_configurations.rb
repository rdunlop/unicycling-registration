class AddStandardSkillToEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :standard_skill, :boolean, default: false
  end
end
