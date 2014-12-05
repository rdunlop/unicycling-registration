class RenameStateToStateCode < ActiveRecord::Migration
  def change
    rename_column :contact_details, :state, :state_code
  end
end
