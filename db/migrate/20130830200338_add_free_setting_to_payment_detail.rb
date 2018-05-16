class AddFreeSettingToPaymentDetail < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_details, :free, :boolean, default: false
  end
end
