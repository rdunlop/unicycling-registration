class CreateCouponCodes < ActiveRecord::Migration
  def change
    create_table :coupon_codes do |t|
      t.string :name
      t.string :code
      t.string :description
      t.integer :max_num_uses, default: 0
      t.decimal :price
      t.timestamps
    end

    create_table :coupon_code_expense_items do |t|
      t.references :coupon_code
      t.references :expense_item
      t.timestamps
    end
  end
end
