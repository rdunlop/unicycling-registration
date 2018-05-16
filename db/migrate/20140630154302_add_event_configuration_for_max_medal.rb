class AddEventConfigurationForMaxMedal < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :max_award_place, :integer, default: 5
  end
end
