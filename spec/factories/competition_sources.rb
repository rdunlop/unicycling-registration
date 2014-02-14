# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition_source do
    target_competition factory: :competition
    competition nil
    event_category nil
    max_place nil
    gender_filter "Both"
    before(:create) do |competition_source|
      if competition_source.event_category.nil?
        ev = FactoryGirl.create(:event)
        competition_source.event_category = ev.event_categories.first
      end
    end
  end
end
