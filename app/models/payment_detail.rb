class PaymentDetail < ActiveRecord::Base
  attr_accessible :amount, :payment_id, :registrant_id

  validates :payment_id, :presence => true
  validates :registrant_id, :presence => true
  validates :amount, :presence => true

  belongs_to :payment
  belongs_to :registrant #XXX has_one?
end
