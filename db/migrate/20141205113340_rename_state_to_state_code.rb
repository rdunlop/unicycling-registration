class RenameStateToStateCode < ActiveRecord::Migration[4.2]
  def change
    rename_column :contact_details, :state, :state_code
  end
end
