class AddEventConfigurationForMaxMedal < ActiveRecord::Migration
  def change
    add_column :event_configurations, :max_award_place, :integer, default: 5
  end
end
