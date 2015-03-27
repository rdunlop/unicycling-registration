# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  registrant_id      :integer
#  declined           :boolean          default(FALSE), not null
#  accepted_readonly  :boolean          default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  accepted_readwrite :boolean          default(FALSE), not null
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

  def status
    return "Declined" if declined
    return "Accepted" if accepted_readonly
    return "Full Access" if accepted_readwrite
    "New"
  end
end
