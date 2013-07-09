# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :boundary_score do
    competitor { FactoryGirl.create(:event_competitor) }
    judge # FactoryGirl
    number_of_people 3
    major_dismount 0
    minor_dismount 0
    major_boundary 0
    minor_boundary 0
  end
end
