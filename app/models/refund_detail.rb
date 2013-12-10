class RefundDetail < ActiveRecord::Base
  validates :payment_detail_id, :presence => true

  belongs_to :refund
  belongs_to :payment_detail

  after_save :touch_payment_detail

  def touch_payment_detail
    payment_detail.touch
  end


  def to_s
    payment_detail
  end
end
