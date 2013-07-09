# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :score do
    competitor { FactoryGirl.create(:event_competitor) }
    judge
    val_1 1.1
    val_2 1.2
    val_3 1.3
    val_4 1.4
    notes 'this is a factory score'
  end
end
