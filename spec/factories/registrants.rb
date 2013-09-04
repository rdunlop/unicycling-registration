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
      @ws20 = FactoryGirl.create(:wheel_size_20)
      @ws24 = FactoryGirl.create(:wheel_size_24)
    }
  end
end
