class AddEmailNotificationToCoupons < ActiveRecord::Migration[4.2]
  def change
    add_column :coupon_codes, :inform_emails, :text
  end
end
