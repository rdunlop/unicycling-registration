# == Schema Information
#
# Table name: payment_details
#
#  id              :integer          not null, primary key
#  payment_id      :integer
#  registrant_id   :integer
#  amount          :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  expense_item_id :integer
#  details         :string(255)
#  free            :boolean          default(FALSE)
#
# Indexes
#
#  index_payment_details_expense_item_id  (expense_item_id)
#  index_payment_details_payment_id       (payment_id)
#  index_payment_details_registrant_id    (registrant_id)
#

class PaymentDetail < ActiveRecord::Base
  include CachedSetModel

  validates :payment, :registrant_id, :expense_item, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  has_paper_trail

  belongs_to :registrant, touch: true
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
  has_one :refund_detail

  delegate :has_details, :details_label, :details_description, to: :expense_item

  # excludes refunded items
  scope :completed, -> { includes(:payment).includes(:refund_detail).where(:payments => {:completed => true}).where({:refund_details => {:payment_detail_id => nil}}) }

  scope :paid, -> { includes(:payment).where(:payments => {:completed => true}).where(:free => false) }

  scope :free, -> { includes(:payment).where(:payments => {:completed => true}).where(:free => true) }
  scope :refunded, -> { includes(:payment).includes(:refund_detail).where(:payments => {:completed => true}).where.not({:refund_details => {:payment_detail_id => nil}}) }

  def self.cache_set_field
    :expense_item_id
  end

  def refunded?
    !refund_detail.nil?
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

  def to_s
    res = ""
    res += expense_item.to_s
    if refunded?
      res += " (Refunded)"
    end
    res
  end

end
