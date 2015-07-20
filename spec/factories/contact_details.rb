# == Schema Information
#
# Table name: contact_details
#
#  id                              :integer          not null, primary key
#  registrant_id                   :integer
#  address                         :string(255)
#  city                            :string(255)
#  state_code                      :string(255)
#  zip                             :string(255)
#  country_residence               :string(255)
#  country_representing            :string(255)
#  phone                           :string(255)
#  mobile                          :string(255)
#  email                           :string(255)
#  club                            :string(255)
#  club_contact                    :string(255)
#  usa_member_number               :string(255)
#  emergency_name                  :string(255)
#  emergency_relationship          :string(255)
#  emergency_attending             :boolean          default(FALSE), not null
#  emergency_primary_phone         :string(255)
#  emergency_other_phone           :string(255)
#  responsible_adult_name          :string(255)
#  responsible_adult_phone         :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  usa_confirmed_paid              :boolean          default(FALSE), not null
#  usa_family_membership_holder_id :integer
#  birthplace                      :string
#  italian_fiscal_code             :string
#
# Indexes
#
#  index_contact_details_on_registrant_id  (registrant_id) UNIQUE
#  index_contact_details_registrant_id     (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact_detail do
    address "1234 fake street"
    city "madison"
    state_code "IL"
    country_residence "US"
    zip "12345"
    phone "PhoMyString"
    mobile "IMobMyString"
    email "EmailMyString"
    club "TCUC"
    club_contact "Connie Cotter"
    usa_member_number "00001"
    emergency_name "Jane Doe"
    emergency_relationship "SO"
    emergency_attending false
    emergency_primary_phone "306-555-1212"
    emergency_other_phone nil
    responsible_adult_name nil
    responsible_adult_phone nil
  end
end
