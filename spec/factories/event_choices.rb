# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  cell_type                   :string
#  multiple_values             :string
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  optional                    :boolean          default(FALSE), not null
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#
# Indexes
#
#  index_event_choices_on_event_id_and_position  (event_id,position)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :event_choice do
    event # FactoryGIrl
    cell_type { "boolean" }
    multiple_values { nil }
    sequence(:label) { |n| "Event_choice #{n} chosen" }
    optional { false }
  end
end
