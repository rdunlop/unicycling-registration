# == Schema Information
#
# Table name: registrants
#
#  id                      :integer          not null, primary key
#  first_name              :string(255)
#  middle_initial          :string(255)
#  last_name               :string(255)
#  birthday                :date
#  gender                  :string(255)
#  state                   :string(255)
#  country_residence       :string(255)
#  phone                   :string(255)
#  mobile                  :string(255)
#  email                   :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#  competitor              :boolean
#  club                    :string(255)
#  club_contact            :string(255)
#  usa_member_number       :string(255)
#  emergency_name          :string(255)
#  emergency_relationship  :string(255)
#  emergency_attending     :boolean
#  emergency_primary_phone :string(255)
#  emergency_other_phone   :string(255)
#  responsible_adult_name  :string(255)
#  responsible_adult_phone :string(255)
#  address                 :string(255)
#  city                    :string(255)
#  zip                     :string(255)
#  deleted                 :boolean
#  bib_number              :integer
#  wheel_size_id           :integer
#  age                     :integer
#  ineligible              :boolean          default(FALSE)
#  volunteer               :boolean
#  country_representing    :string(255)
#  online_waiver_signature :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant do
    sequence(:first_name) {|n| "FirstMyString #{n}" }
    middle_initial "MMyString"
    last_name "LastMyString"
    birthday Date.new(1990,11,10)
    gender "Male"
    address "1234 fake street"
    city "madison"
    state "StateMyString"
    country_residence "CountMyString"
    zip "12345"
    phone "PhoMyString"
    mobile "IMobMyString"
    email "EmailMyString"
    user # FactoryGirl
    competitor true
    club "TCUC"
    club_contact "Connie Cotter"
    usa_member_number "00001"
    emergency_name "Caitlin Goeres"
    emergency_relationship "SO"
    emergency_attending false
    emergency_primary_phone "306-555-1212"
    emergency_other_phone nil
    responsible_adult_name nil
    responsible_adult_phone nil
    ineligible false

    factory :competitor do
      competitor true
    end
    factory :noncompetitor do
      competitor false
    end

    factory :minor_competitor do
      competitor true
      responsible_adult_name "Bob Smith"
      responsible_adult_phone "911"
    end
    before(:create) {
      if WheelSize.count == 0
        @ws20 = FactoryGirl.create(:wheel_size_20)
        @ws24 = FactoryGirl.create(:wheel_size_24)
      end
    }
  end
end
