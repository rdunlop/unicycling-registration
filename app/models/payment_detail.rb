class PaymentDetail < ActiveRecord::Base
  validates :payment, :registrant_id, :expense_item, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  has_paper_trail

  belongs_to :registrant
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
  has_one :refund_detail

  after_touch :touch_registrant

  # excludes refunded items
  scope :completed, includes(:payment).includes(:refund_detail).where(:payments => {:completed => true}).where({:refund_details => {:payment_detail_id => nil}})


  def touch_registrant
    registrant.touch
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
