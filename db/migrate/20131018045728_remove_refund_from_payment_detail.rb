class RemoveRefundFromPaymentDetail < ActiveRecord::Migration
  def up
    remove_column :payment_details, :refund
  end

  def down
    add_column :payment_details, :refund, :boolean, default: false
  end
end
