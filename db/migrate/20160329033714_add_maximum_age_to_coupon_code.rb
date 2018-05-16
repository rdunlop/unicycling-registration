class AddMaximumAgeToCouponCode < ActiveRecord::Migration[4.2]
  def change
    add_column :coupon_codes, :maximum_registrant_age, :integer
  end
end
