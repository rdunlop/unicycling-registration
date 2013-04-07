# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wheel_size do
    position 1
    description "MyString"

    factory :wheel_size_24 do
      description "24\" Wheel"
    end

    factory :wheel_size_20 do
      description "20\" Wheel"
    end
  end
end
