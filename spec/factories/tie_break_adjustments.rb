# == Schema Information
#
# Table name: distance_attempts
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  distance      :integer
#  fault         :boolean
#  judge_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tie_break_adjustment do
    association :competitor, :factory => :event_competitor
    judge      # use FactoryGirl to create
    tie_break_place 1
  end
end
