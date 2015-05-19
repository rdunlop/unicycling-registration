class RemoveWaiverUrl < ActiveRecord::Migration
  def change
    remove_column :event_configurations, :waiver_url, :string
  end
end
