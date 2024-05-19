FactoryBot.define do
  factory :member, class: 'Member' do
    association(:registrant, factory: :registrant) # FactoryBot
    association :competitor, factory: :event_competitor
  end
end
