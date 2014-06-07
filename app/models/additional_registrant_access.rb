# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  registrant_id     :integer
#  declined          :boolean
#  accepted_readonly :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_additional_registrant_accesses_registrant_id  (registrant_id)
#  index_additional_registrant_accesses_user_id        (user_id)
#

class AdditionalRegistrantAccess < ActiveRecord::Base
  belongs_to :registrant
  belongs_to :user
  validates :user, :registrant, :presence => true
  validates :registrant_id, :uniqueness => {:scope => [:user_id]}

  scope :permitted, -> { where(:accepted_readonly => true) }
  scope :need_reply, -> { where(:accepted_readonly => false, :declined => false) }

  after_initialize :init

  def init
    self.accepted_readonly = false if self.accepted_readonly.nil?
    self.declined = false if self.declined.nil?
  end

  def status
    return "Declined" if declined
    return "Accepted" if accepted_readonly
    "New"
  end
end
