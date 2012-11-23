# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant do
    first_name "FirstMyString"
    middle_initial "MMyString"
    last_name "LastMyString"
    birthday "2012-11-10"
    gender "Male"
    address_line_1 "Adr1MyString"
    address_line_2 "Adr2MyString"
    city "CityMyString"
    state "StateMyString"
    country "CountMyString"
    zip_code "ZipMyString"
    phone "PhoMyString"
    mobile "IMobMyString"
    email "EmailMyString"
    user # FactoryGirl
    competitor true

    factory :competitor do
      competitor true
    end
    factory :noncompetitor do
      competitor false
    end
  end
end
