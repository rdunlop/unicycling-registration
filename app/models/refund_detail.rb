class RefundDetail < ActiveRecord::Base
  validates :payment_detail_id, :presence => true

  belongs_to :refund
  belongs_to :payment_detail

  after_save :create_required_registrant_item
  after_save :touch_payment_detail

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
