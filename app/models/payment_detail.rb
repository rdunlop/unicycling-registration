class PaymentDetail < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :amount, :payment_id, :registrant_id, :expense_item_id, :details, :free
  attr_accessible :refund

  validates :payment, :registrant_id, :amount, :expense_item, :presence => true

  has_paper_trail

  belongs_to :registrant
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item

  scope :completed, includes(:payment).where(:payments => {:completed => true})

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
    expense_item.to_s
  end

end
