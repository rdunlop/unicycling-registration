# == Schema Information
#
# Table name: distance_attempts
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  distance      :decimal(4, )
#  fault         :boolean          default(FALSE), not null
#  judge_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_distance_attempts_competitor_id  (competitor_id)
#  index_distance_attempts_judge_id       (judge_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :distance_attempt do
    association :competitor, factory: %i[event_competitor with_high_jump_competition]
    judge # use FactoryGirl to create
    distance 220
    fault false
  end
end
