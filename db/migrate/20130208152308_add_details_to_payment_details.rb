class AddDetailsToPaymentDetails < ActiveRecord::Migration
  def change
    add_column :payment_details, :details, :string
  end
end
