class RemoveWaiverUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :event_configurations, :waiver_url, :string
  end
end
