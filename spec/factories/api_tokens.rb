FactoryBot.define do
  factory :api_token do
    sequence(:description) { |n| "Token #{n}" }

    sequence(:token) { |n| "token-value-#{n}" }
  end
end

# == Schema Information
#
# Table name: api_tokens
#
#  id          :bigint           not null, primary key
#  token       :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
