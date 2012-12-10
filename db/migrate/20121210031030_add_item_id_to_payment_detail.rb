class AddItemIdToPaymentDetail < ActiveRecord::Migration
  def change
    add_column :payment_details, :expense_item_id, :integer
  end
end
