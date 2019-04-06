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

  after_commit :update_usa_membership_status, if: proc { EventConfiguration.singleton.organization_membership_usa? }

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

  private

  def update_usa_membership_status
    return unless previous_changes.key?(:system_member_number) || previous_changes.key?(:manual_member_number)

    UpdateUsaMembershipStatusWorker.perform_async(registrant_id)
  end
end
