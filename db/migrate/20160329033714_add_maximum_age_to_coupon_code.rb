class AddMaximumAgeToCouponCode < ActiveRecord::Migration
  def change
    add_column :coupon_codes, :maximum_registrant_age, :integer
  end
end
