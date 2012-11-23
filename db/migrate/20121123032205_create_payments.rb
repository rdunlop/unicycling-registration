class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.boolean :completed
      t.boolean :cancelled
      t.string :transaction_id
      t.datetime :completed_date

      t.timestamps
    end
  end
end
