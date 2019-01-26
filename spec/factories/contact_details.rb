# == Schema Information
#
# Table name: contact_details
#
#  id                                         :integer          not null, primary key
#  registrant_id                              :integer
#  address                                    :string
#  city                                       :string
#  state_code                                 :string
#  zip                                        :string
#  country_residence                          :string
#  country_representing                       :string
#  phone                                      :string
#  mobile                                     :string
#  email                                      :string
#  club                                       :string
#  club_contact                               :string
#  organization_member_number                 :string
#  emergency_name                             :string
#  emergency_relationship                     :string
#  emergency_attending                        :boolean          default(FALSE), not null
#  emergency_primary_phone                    :string
#  emergency_other_phone                      :string
#  responsible_adult_name                     :string
#  responsible_adult_phone                    :string
#  created_at                                 :datetime
#  updated_at                                 :datetime
#  organization_membership_manually_confirmed :boolean          default(FALSE), not null
#  birthplace                                 :string
#  italian_fiscal_code                        :string
#  organization_membership_system_confirmed   :boolean          default(FALSE), not null
#  organization_membership_system_status      :string
#
# Indexes
#
#  index_contact_details_on_registrant_id  (registrant_id) UNIQUE
#  index_contact_details_registrant_id     (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contact_detail do
    address { "1234 fake street" }
    city { "madison" }
    state_code { "IL" }
    country_residence { "US" }
    country_representing { "US" }
    zip { "12345" }
    phone { "PhoMyString" }
    mobile { "IMobMyString" }
    sequence(:email) { |n| "EmailMyString+#{n}@example.com" }
    club { "TCUC" }
    club_contact { "Connie Cotter" }
    emergency_name { "Jane Doe" }
    emergency_relationship { "SO" }
    emergency_attending { false }
    emergency_primary_phone { "306-555-1212" }
    emergency_other_phone { nil }
    responsible_adult_name { nil }
    responsible_adult_phone { nil }
  end
end
