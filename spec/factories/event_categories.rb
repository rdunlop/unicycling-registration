# == Schema Information
#
# Table name: event_categories
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  position        :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  age_range_start :integer          default(0)
#  age_range_end   :integer          default(100)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_category do
    event # FactoryGirl
    sequence(:name) {|n| "EventCategory #{n}"}
    position 1
  end
end
