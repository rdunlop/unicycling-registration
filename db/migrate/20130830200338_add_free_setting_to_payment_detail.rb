class AddFreeSettingToPaymentDetail < ActiveRecord::Migration
  def change
    add_column :payment_details, :free, :boolean, default: false
  end
end
