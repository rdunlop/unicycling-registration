class RenameOnlineWaiverTextToCustomWaiverText < ActiveRecord::Migration
  def change
    rename_column :event_configurations, :online_waiver_text, :custom_waiver_text
  end
end
