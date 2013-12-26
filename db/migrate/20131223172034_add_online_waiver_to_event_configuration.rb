class AddOnlineWaiverToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :has_online_waiver, :boolean
    add_column :event_configurations, :online_waiver_text, :text
  end
end
