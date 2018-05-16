class AddOnlineWaiverToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :has_online_waiver, :boolean
    add_column :event_configurations, :online_waiver_text, :text
  end
end
