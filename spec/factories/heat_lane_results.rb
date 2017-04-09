# == Schema Information
#
# Table name: heat_lane_results
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  heat           :integer          not null
#  lane           :integer          not null
#  status         :string           not null
#  minutes        :integer          not null
#  seconds        :integer          not null
#  thousands      :integer          not null
#  raw_data       :string
#  entered_at     :datetime         not null
#  entered_by_id  :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :heat_lane_result do
    competition # FactoryGirl
    minutes 1
    seconds 1
    thousands 1
    sequence(:heat) { |n| n }
    sequence(:lane) { |n| n }
    status "active"
    raw_data "MyString"
    entered_at DateTime.current
    association :entered_by, factory: :user

    trait :disqualified do
      status "DQ"
    end
  end
end
