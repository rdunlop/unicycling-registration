# == Schema Information
#
# Table name: combined_competitions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  use_age_group_places          :boolean          default(FALSE), not null
#  percentage_based_calculations :boolean          default(FALSE), not null
#  tie_break_by_firsts           :boolean          default(TRUE), not null
#
# Indexes
#
#  index_combined_competitions_on_name  (name) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :combined_competition do
    sequence(:name) { |n| "MyString #{n}" }
    tie_break_by_firsts true
  end
end
