class PaymentDetail < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :amount, :payment_id, :registrant_id, :expense_item_id, :details, :free

  validates :payment, :registrant_id, :expense_item, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  has_paper_trail

  belongs_to :registrant
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
  has_one :refund_detail

  scope :completed, includes(:payment).where(:payments => {:completed => true})

  # all of the PaymentDetails which do not have a refund applied
  def self.all_paid
    PaymentDetail.completed.includes(:refund_detail).where({:refund_detail => {:payment_detail_id => nil}})
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
