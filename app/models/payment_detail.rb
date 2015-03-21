# == Schema Information
#
# Table name: payment_details
#
#  id              :integer          not null, primary key
#  payment_id      :integer
#  registrant_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#  expense_item_id :integer
#  details         :string(255)
#  free            :boolean          default(FALSE)
#  refunded        :boolean          default(FALSE)
#  amount_cents    :integer
#
# Indexes
#
#  index_payment_details_expense_item_id  (expense_item_id)
#  index_payment_details_payment_id       (payment_id)
#  index_payment_details_registrant_id    (registrant_id)
#

class PaymentDetail < ActiveRecord::Base
  include CachedSetModel
  include HasDetailsDescription

  validates :payment, :registrant_id, :expense_item, :presence => true
  validate :registrant_must_be_valid

  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  has_paper_trail

  belongs_to :registrant, touch: true
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
  has_one :refund_detail
  has_one :payment_detail_coupon_code

  delegate :has_details, :details_label, to: :expense_item

  # excludes refunded items
  scope :completed, -> { includes(:payment).includes(:refund_detail).where(:payments => {:completed => true}).where({:refund_details => {:payment_detail_id => nil}}) }

  scope :paid, -> { includes(:payment).where(:payments => {:completed => true}).where(:free => false) }

  scope :free, -> { includes(:payment).where(:payments => {:completed => true}).where(:free => true) }
  scope :refunded, -> { completed.where(refunded: true) }

  scope :with_coupon, -> { includes(:payment_detail_coupon_code).where.not(payment_detail_coupon_codes: {payment_detail_id: nil } ) }

  def self.cache_set_field
    :expense_item_id
  end

  def registrant_must_be_valid
    if registrant && (!registrant.validated? || registrant.invalid?)
      errors[:registrant] = "Registrant #{registrant.to_s} form is incomplete"
      return false
    end
    true
  end

  def base_cost
    return 0 if free

    expense_item.cost
  end

  def tax
    return 0 if free

    expense_item.tax
  end

  def cost
    return 0 if free
    return ((100 - refund_detail.percentage.to_f) / 100) * amount if refunded?

    amount
  end

  # update the amount owing for this payment_detail, based on the coupon code applied
  def recalculate!
    if payment_detail_coupon_code.nil?
      update_attribute(:amount, expense_item.total_cost)
    else
      update_attribute(:amount, payment_detail_coupon_code.price)
    end
  end

  def to_s
    res = ""
    res += expense_item.to_s
    if refunded?
      res += " (Refunded)"
    end
    if coupon_applied?
      res += " (Discount applied)"
    end
    res
  end

  def inform_of_coupon
    if payment_detail_coupon_code.present? && payment_detail_coupon_code.inform?
      PaymentMailer.delay.coupon_used(self.id)
    end
  end

  def coupon_applied?
    payment_detail_coupon_code.present?
  end
end
