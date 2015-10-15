class AddWaiverAcceptanceBoolean < ActiveRecord::Migration
  def up
    add_column :registrants, :online_waiver_acceptance, :boolean, null: false, default: false
    execute "UPDATE registrants SET online_waiver_acceptance = TRUE WHERE online_waiver_signature IS NOT NULL"
  end

  def down
    remove_column :registrants, :online_waiver_acceptance
  end
end
