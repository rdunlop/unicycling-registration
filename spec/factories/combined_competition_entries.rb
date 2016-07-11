# == Schema Information
#
# Table name: combined_competition_entries
#
#  id                      :integer          not null, primary key
#  combined_competition_id :integer
#  abbreviation            :string(255)
#  tie_breaker             :boolean          default(FALSE), not null
#  points_1                :integer
#  points_2                :integer
#  points_3                :integer
#  points_4                :integer
#  points_5                :integer
#  points_6                :integer
#  points_7                :integer
#  points_8                :integer
#  points_9                :integer
#  points_10               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  competition_id          :integer
#  base_points             :integer
#  distance                :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :combined_competition_entry do
    combined_competition # FactoryGirl
    abbreviation "MyString"
    tie_breaker false
    points_1 50
    points_2 42
    points_3 34
    points_4 27
    points_5 21
    points_6 15
    points_7 10
    points_8 6
    points_9 3
    points_10 1
    competition # FactoryGirl
  end
end
