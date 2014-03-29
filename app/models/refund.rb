# == Schema Information
#
# Table name: refunds
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  refund_date :datetime
#  note        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  percentage  :integer          default(100)
#

class Refund < ActiveRecord::Base
  validates :refund_date, :user_id, :note, :percentage, :presence => true
  validates :percentage, inclusion: { in: 0..100 }

  validates_associated :refund_details

  belongs_to :user
  has_many :refund_details, :dependent => :destroy
end
