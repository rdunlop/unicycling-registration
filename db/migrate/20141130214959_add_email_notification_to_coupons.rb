class AddEmailNotificationToCoupons < ActiveRecord::Migration
  def change
    add_column :coupon_codes, :inform_emails, :text
  end
end
