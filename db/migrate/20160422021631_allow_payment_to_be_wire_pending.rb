class AllowPaymentToBeWirePending < ActiveRecord::Migration
  def up
    add_column :payments, :offline_pending, :boolean, default: false, null: false
    add_column :payments, :offline_pending_date, :datetime
  end

  def down
    remove_column :payments, :offline_pending
    remove_column :payments, :offline_pending_date
  end
end
