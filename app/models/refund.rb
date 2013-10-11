class Refund < ActiveRecord::Base
  attr_accessible :note, :refund_date, :user_id

  validates :refund_date, :presence => true
  validates :user_id, :presence => true
  validates :note, :presence => true

  belongs_to :user
end
