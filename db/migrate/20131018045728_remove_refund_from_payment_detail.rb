class RemoveRefundFromPaymentDetail < ActiveRecord::Migration[4.2]
  def up
    remove_column :payment_details, :refund
  end

  def down
    add_column :payment_details, :refund, :boolean, default: false
  end
end
