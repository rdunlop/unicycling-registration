# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_competitor, :class => Competitor do
    event_category  {FactoryGirl.create(:event).event_categories.first}
    sequence(:position)
    after(:create) { |comp| FactoryGirl.create(:member, :competitor => comp)}
  end

  factory :member, :class => Member do
    registrant
    competitor {FactoryGirl.create(:event_competitor) }
  end

end
