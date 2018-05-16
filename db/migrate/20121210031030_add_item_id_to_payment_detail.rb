class AddItemIdToPaymentDetail < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_details, :expense_item_id, :integer
  end
end
