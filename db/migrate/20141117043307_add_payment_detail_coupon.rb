class AddPaymentDetailCoupon < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_detail_coupon_codes do |t|
      t.references :payment_detail
      t.references :coupon_code
      t.timestamps
    end
  end
end
