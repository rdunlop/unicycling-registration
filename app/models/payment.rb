class Payment < ActiveRecord::Base
  attr_accessible :cancelled, :completed, :completed_date, :transaction_id, :user_id

  validates :user_id, :presence => true

  belongs_to :user

  after_initialize :init

  def init
    self.cancelled = false if self.cancelled.nil?
    self.completed = false if self.completed.nil?
  end
end
