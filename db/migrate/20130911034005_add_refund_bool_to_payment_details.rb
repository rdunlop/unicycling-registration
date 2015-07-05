class AddRefundBoolToPaymentDetails < ActiveRecord::Migration
  def change
    add_column :payment_details, :refund, :boolean, default: false
  end
end
