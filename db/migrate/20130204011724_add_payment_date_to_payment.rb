class AddPaymentDateToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :payment_date, :string
  end
end
