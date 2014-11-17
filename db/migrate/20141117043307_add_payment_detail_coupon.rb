class AddPaymentDetailCoupon < ActiveRecord::Migration
  def change
    create_table :payment_detail_coupons do |t|
      t.references :payment_detail
      t.references :coupon_code
      t.timestamps
    end
  end
end
