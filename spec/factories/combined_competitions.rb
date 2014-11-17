# == Schema Information
#
# Table name: combined_competitions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  use_age_group_places          :boolean          default(FALSE)
#  percentage_based_calculations :boolean          default(FALSE)
#
# Indexes
#
#  index_combined_competitions_on_name  (name) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :combined_competition do
    sequence(:name) { |n| "MyString #{n}" }
  end
end
