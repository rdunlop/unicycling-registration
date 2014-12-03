class CreateRefundModel < ActiveRecord::Migration
  def up
    create_table :refunds do |t|
      t.integer :user_id
      t.datetime :refund_date
      t.string :note
      t.timestamps
    end
    create_table :refund_details do |t|
      t.integer :refund_id
      t.integer :payment_detail_id
      t.timestamps
    end
  end

  def down
    drop_table :refunds
    drop_table :refund_details
  end
end
