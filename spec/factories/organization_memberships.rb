# == Schema Information
#
# Table name: organization_memberships
#
#  id                   :bigint           not null, primary key
#  registrant_id        :bigint
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
#  index_organization_memberships_on_registrant_id  (registrant_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :organization_membership do
    manual_member_number { "00001" }
    system_member_number { "00001" }
  end
end
