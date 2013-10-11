class RefundDetail < ActiveRecord::Base
  attr_accessible :payment_detail_id, :refund_id

  validates :payment_detail_id, :presence => true
  #validates :refund_id, :presence => true

  belongs_to :refund
  belongs_to :payment_detail
end
