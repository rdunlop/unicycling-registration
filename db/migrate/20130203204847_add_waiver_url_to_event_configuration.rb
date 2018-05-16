class AddWaiverUrlToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :waiver_url, :string
  end
end
