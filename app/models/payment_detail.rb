class PaymentDetail < ActiveRecord::Base
  attr_accessible :amount, :payment_id, :registrant_id, :expense_item_id, :details

  validates :payment, :presence => true
  validates :registrant_id, :presence => true
  validates :amount, :presence => true
  validates :expense_item, :presence => true

  has_paper_trail

  belongs_to :registrant #XXX has_one?
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
end
