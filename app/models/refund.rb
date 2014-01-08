class Refund < ActiveRecord::Base
  validates :refund_date, :presence => true
  validates :user_id, :presence => true
  validates :note, :presence => true

  validates_associated :refund_details

  belongs_to :user
  has_many :refund_details, :dependent => :destroy
end
