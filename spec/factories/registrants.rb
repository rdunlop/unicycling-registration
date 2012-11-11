# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant do
    first_name "MyString"
    middle_initial "MyString"
    last_name "MyString"
    birthday "2012-11-10"
    gender "Male"
    address_line_1 "MyString"
    address_line_2 "MyString"
    city "MyString"
    state "MyString"
    country "MyString"
    zip_code "MyString"
    phone "MyString"
    mobile "MyString"
    email "MyString"
  end
end
