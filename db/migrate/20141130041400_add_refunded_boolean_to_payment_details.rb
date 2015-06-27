class AddRefundedBooleanToPaymentDetails < ActiveRecord::Migration
  class PaymentDetail < ActiveRecord::Base
    has_one :refund_detail
  end
  class RefundDetail < ActiveRecord::Base
    belongs_to :payment_detail
  end

  def up
    add_column :payment_details, :refunded, :boolean, default: false
    PaymentDetail.reset_column_information
    PaymentDetail.includes(:refund_detail).where.not(refund_details: {payment_detail_id: nil}).each do |pd|
      pd.update_attribute(:refunded, true)
    end
  end

  def down
    remove_column :payment_details, :refunded
  end
end
