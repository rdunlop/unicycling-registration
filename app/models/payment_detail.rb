class PaymentDetail < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :amount, :payment_id, :registrant_id, :expense_item_id, :details, :free
  attr_accessible :refund

  validates :payment, :registrant_id, :expense_item, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  has_paper_trail

  belongs_to :registrant
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
  has_many :refund_details

  scope :completed, includes(:payment).where(:payments => {:completed => true})

  # all of the PaymentDetails which do not have a refund applied
  def self.all_paid
    PaymentDetail.completed.includes(:refund_details).where({:refund_details => {:payment_detail_id => nil}})
  end

  def refunded?
    refund_details.count > 0
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

    if refund
      -amount
    else
      amount
    end
  end

  def to_s
    res = ""
    if refund
      res += "Refund: "
    end
    res += expense_item.to_s
  end

end
