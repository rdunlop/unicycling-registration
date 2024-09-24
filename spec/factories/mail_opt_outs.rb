FactoryBot.define do
  factory :mail_opt_out do
    sequence(:email) { |n| "EmailMyString+#{n}@example.com" }
    opted_out { true }
  end
end
