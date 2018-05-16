class AllowDisablingOfDefaultWheelSizeQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :registrants_should_specify_default_wheel_size, :boolean, default: true, null: false
  end
end
