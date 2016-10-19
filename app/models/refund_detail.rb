# == Schema Information
#
# Table name: refund_details
#
#  id                :integer          not null, primary key
#  refund_id         :integer
#  payment_detail_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_refund_details_on_payment_detail_id  (payment_detail_id) UNIQUE
#  index_refund_details_on_refund_id          (refund_id)
#

class RefundDetail < ApplicationRecord
  validates :payment_detail_id, presence: true

  belongs_to :refund
  belongs_to :payment_detail, touch: true

  after_save :create_required_registrant_item
  after_save :mark_payment_detail_as_refunded

  delegate :percentage, to: :refund
  delegate :registrant, to: :payment_detail

  def create_required_registrant_item
    reg = payment_detail.registrant
    reg.create_associated_required_expense_items
    reg.save(validate: false)
  end

  def mark_payment_detail_as_refunded
    payment_detail.update_attribute(:refunded, true) unless payment_detail.refunded?
  end

  def to_s
    payment_detail
  end
end
