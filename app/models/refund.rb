class Refund < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :note, :refund_date, :user_id

  validates :refund_date, :presence => true
  validates :user_id, :presence => true
  validates :note, :presence => true

  validates_associated :refund_details

  belongs_to :user
  has_many :refund_details
end
