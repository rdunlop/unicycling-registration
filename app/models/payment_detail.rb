class PaymentDetail < ActiveRecord::Base
  attr_accessible :amount, :payment_id, :registrant_id

  validates :payment, :presence => true
  validates :registrant_id, :presence => true
  validates :amount, :presence => true

  belongs_to :registrant #XXX has_one?
  belongs_to :payment, :inverse_of => :payment_details
end
