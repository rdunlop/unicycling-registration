class RenameOnlineWaiverTextToCustomWaiverText < ActiveRecord::Migration[4.2]
  def change
    rename_column :event_configurations, :online_waiver_text, :custom_waiver_text
  end
end
