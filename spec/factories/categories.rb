# == Schema Information
#
# Table name: categories
#
#  id           :integer          not null, primary key
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  info_url     :string
#  info_page_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "TheCategory #{n}" }
  end
end
