class AddStyleNameToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :style_name, :string
  end
end
