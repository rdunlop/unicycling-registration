class AddDetailsToPaymentDetails < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_details, :details, :string
  end
end
