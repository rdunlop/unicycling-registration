class Refund < ActiveRecord::Base
  validates :refund_date, :user_id, :note, :percentage, :presence => true
  validates :percentage, inclusion: { in: 0..100 }

  validates_associated :refund_details

  belongs_to :user
  has_many :refund_details, :dependent => :destroy
end
