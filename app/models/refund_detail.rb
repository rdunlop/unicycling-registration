class RefundDetail < ActiveRecord::Base
  validates :payment_detail_id, :presence => true

  belongs_to :refund
  belongs_to :payment_detail

  def to_s
    payment_detail
  end
end
