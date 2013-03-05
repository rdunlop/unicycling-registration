# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_skill_entry do
    sequence(:number)
    sequence(:letter) { |n| 
        x = "a"
        n.times do |i|
            x = x.next
        end
        x
    }
    points "1.3"
    description "riding - 8"
  end
end
