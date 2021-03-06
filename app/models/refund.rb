# == Schema Information
#
# Table name: refunds
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  refund_date :datetime
#  note        :string
#  created_at  :datetime
#  updated_at  :datetime
#  percentage  :integer          default(100)
#
# Indexes
#
#  index_refunds_on_user_id  (user_id)
#

class Refund < ApplicationRecord
  include CachedModel

  validates :refund_date, :user, :note, :percentage, presence: true
  validates :percentage, inclusion: { in: 0..100 }

  validates_associated :refund_details

  belongs_to :user
  has_many :refund_details, dependent: :destroy

  def self.build_from_details(options)
    pd = options[:registrant].paid_details.find { |payment_detail| payment_detail.line_item == options[:item] }
    refund = Refund.new(
      refund_date: Time.current,
      note: options[:note],
      percentage: 100
    )
    refund.refund_details.build(
      payment_detail: pd
    )
    refund
  end
end
