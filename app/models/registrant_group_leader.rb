# == Schema Information
#
# Table name: registrant_group_members
#
#  id                      :integer          not null, primary key
#  registrant_id           :integer
#  registrant_group_id     :integer
#  created_at              :datetime
#  updated_at              :datetime
#  additional_details_type :string
#  additional_details_id   :integer
#
# Indexes
#
#  index_registrant_group_members_on_registrant_group_id  (registrant_group_id)
#  index_registrant_group_members_on_registrant_id        (registrant_id)
#  reg_group_reg_group                                    (registrant_id,registrant_group_id) UNIQUE
#

class RegistrantGroupLeader < ApplicationRecord
  belongs_to :registrant_group, inverse_of: :registrant_group_leaders
  belongs_to :user

  validates :registrant_group_id, uniqueness: {scope: [:user_id]}
  validates :registrant_group, presence: true
  validates :user, presence: true
end
