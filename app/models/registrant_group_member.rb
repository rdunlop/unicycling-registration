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

class RegistrantGroupMember < ApplicationRecord
  belongs_to :registrant_group, inverse_of: :registrant_group_members
  belongs_to :registrant
  belongs_to :additional_details, polymorphic: true

  validates :registrant, presence: true
  validates :registrant_id, uniqueness: {scope: [:registrant_group_id]}
  validates :registrant_group, presence: true

  delegate :to_s, to: :registrant_group
end
