class RenameVolunteeDisplayOrderToPosition < ActiveRecord::Migration[4.2]
  def change
    rename_column :volunteer_opportunities, :display_order, :position
  end
end
