# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competitor_id  :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lane_assignment do
    competition # FactoryGirl
    association :competitor, factory: :event_competitor
    heat 1
    lane 1
  end
end
