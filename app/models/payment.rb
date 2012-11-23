class Payment < ActiveRecord::Base
  attr_accessible :cancelled, :completed, :completed_date, :transaction_id, :user_id
  attr_accessible :payment_details_attributes


  validates :user_id, :presence => true

  belongs_to :user
  has_many :payment_details, :inverse_of => :payment
  accepts_nested_attributes_for :payment_details

  after_initialize :init

  def init
    self.cancelled = false if self.cancelled.nil?
    self.completed = false if self.completed.nil?
  end
end
