# == Schema Information
#
# Table name: refund_details
#
#  id                :integer          not null, primary key
#  refund_id         :integer
#  payment_detail_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class RefundDetail < ActiveRecord::Base
  validates :payment_detail_id, :presence => true

  belongs_to :refund
  belongs_to :payment_detail

  after_save :create_required_registrant_item
  after_save :touch_payment_detail

  delegate :percentage, to: :refund
  delegate :registrant, to: :payment_detail

  def create_required_registrant_item
    reg = payment_detail.registrant
    reg.create_associated_required_expense_items
    reg.save(validate: false)
  end

  def touch_payment_detail
    payment_detail.touch
  end

  def to_s
    payment_detail
  end
end
