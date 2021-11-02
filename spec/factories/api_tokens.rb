FactoryBot.define do
  factory :api_token do
    sequence(:description) { |n| "Token #{n}" }

    sequence(:token) { |n| "token-value-#{n}" }
  end
end
