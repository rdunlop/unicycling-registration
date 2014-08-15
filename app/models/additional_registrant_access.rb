# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  registrant_id      :integer
#  declined           :boolean
#  accepted_readonly  :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  accepted_readwrite :boolean          default(FALSE)
#
# Indexes
#
#  ada_reg_user                                        (registrant_id,user_id) UNIQUE
#  index_additional_registrant_accesses_registrant_id  (registrant_id)
#  index_additional_registrant_accesses_user_id        (user_id)
#

class AdditionalRegistrantAccess < ActiveRecord::Base
  belongs_to :registrant
  belongs_to :user
  validates :user, :registrant, :presence => true
  validates :registrant_id, :uniqueness => {:scope => [:user_id]}

  scope :full_access, -> { where(accepted_readwrite: true ) }
  scope :permitted, -> { where("accepted_readonly = true OR accepted_readwrite = true") }
  scope :need_reply, -> { where(accepted_readwrite: false, accepted_readonly: false, declined: false) }

  after_initialize :init

  def init
    self.accepted_readwrite = false if self.accepted_readwrite.nil?
    self.accepted_readonly = false if self.accepted_readonly.nil?
    self.declined = false if self.declined.nil?
  end

  def status
    return "Declined" if declined
    return "Accepted" if accepted_readonly
    return "Full Access" if accepted_readwrite
    "New"
  end
end
