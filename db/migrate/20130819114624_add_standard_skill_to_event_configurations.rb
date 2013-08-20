class AddStandardSkillToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :standard_skill, :boolean, :default => false
  end
end
