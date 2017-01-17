class AddLimitedNumberOfRegistrants < ActiveRecord::Migration[5.0]
  def change
    add_column :event_configurations, :max_registrants, :integer, default: 0, null: false
  end
end
