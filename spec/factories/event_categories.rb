# == Schema Information
#
# Table name: event_categories
#
#  id                              :integer          not null, primary key
#  event_id                        :integer
#  position                        :integer
#  name                            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  age_range_start                 :integer          default(0)
#  age_range_end                   :integer          default(100)
#  warning_on_registration_summary :boolean          default(FALSE), not null
#
# Indexes
#
#  index_event_categories_event_id                  (event_id,position)
#  index_event_categories_on_event_id_and_name      (event_id,name) UNIQUE
#  index_event_categories_on_event_id_and_position  (event_id,position) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_category do
    event # FactoryGirl
    sequence(:name) {|n| "EventCategory #{n}"}
    position 1
  end
end
