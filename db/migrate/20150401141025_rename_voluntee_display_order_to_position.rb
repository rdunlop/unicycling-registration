class RenameVolunteeDisplayOrderToPosition < ActiveRecord::Migration
  def change
    rename_column :volunteer_opportunities, :display_order, :position
  end
end
