# == Schema Information
#
# Table name: combined_competitions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :combined_competition do
    sequence(:name) { |n| "MyString #{n}" }
  end
end
