class AddRefundBoolToPaymentDetails < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_details, :refund, :boolean, default: false
  end
end
