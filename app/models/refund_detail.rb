class RefundDetail < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :payment_detail_id, :refund_id

  validates :payment_detail_id, :presence => true

  belongs_to :refund
  belongs_to :payment_detail

  def to_s
    payment_detail
  end
end
