class AddStyleNameToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :style_name, :string
  end
end
