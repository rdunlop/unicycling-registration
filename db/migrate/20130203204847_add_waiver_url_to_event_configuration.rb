class AddWaiverUrlToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :waiver_url, :string
  end
end
