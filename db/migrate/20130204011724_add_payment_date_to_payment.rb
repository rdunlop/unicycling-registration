class AddPaymentDateToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :payment_date, :string
  end
end
