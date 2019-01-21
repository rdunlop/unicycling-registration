# == Schema Information
#
# Table name: organization_memberships
#
#  id                   :bigint(8)        not null, primary key
#  registrant_id        :bigint(8)
#  manual_member_number :string
#  system_member_number :string
#  manually_confirmed   :boolean          default(FALSE), not null
#  system_confirmed     :boolean          default(FALSE), not null
#  system_status        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_organization_memberships_on_registrant_id  (registrant_id)
#

class OrganizationMembership < ApplicationRecord
  belongs_to :registrant, inverse_of: :organization_membership, touch: true

  # is this registrant a member of the relevant unicycling federation?
  def organization_membership_confirmed?
    system_confirmed? || manually_confirmed?
  end

  def member_number
    description = []
    description << "Membership ID ##{system_member_number}" if system_member_number.present?
    description << "Legacy ID ##{manual_member_number}" if manual_member_number.present? && system_member_number != manual_member_number

    description.join(", ")
  end
end
