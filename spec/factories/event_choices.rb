# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  cell_type                   :string(255)
#  multiple_values             :string(255)
#  label                       :string(255)
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  autocomplete                :boolean          default(FALSE), not null
#  optional                    :boolean          default(FALSE), not null
#  tooltip                     :string(255)
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#
# Indexes
#
#  index_event_choices_on_event_id_and_position  (event_id,position) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_choice do
    event # FactoryGIrl
    cell_type "boolean"
    multiple_values nil
    label "Event_choice chosen"
    position 1
    autocomplete false
    optional false
  end
end
