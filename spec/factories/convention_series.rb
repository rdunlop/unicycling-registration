FactoryBot.define do
  factory :convention_series do
    sequence(:name) { |n| "The Series #{n}" }
  end
end
