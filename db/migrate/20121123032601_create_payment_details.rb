class CreatePaymentDetails < ActiveRecord::Migration
  def change
    create_table :payment_details do |t|
      t.integer :payment_id
      t.integer :registrant_id
      t.decimal :amount

      t.timestamps
    end
  end
end
