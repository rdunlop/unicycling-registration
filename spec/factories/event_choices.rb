# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  cell_type                   :string(255)
#  multiple_values             :string(255)
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  autocomplete                :boolean          default(FALSE), not null
#  optional                    :boolean          default(FALSE), not null
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_choice do
    event # FactoryGIrl
    cell_type "boolean"
    multiple_values nil
    label "Event_choice chosen"
    autocomplete false
    optional false
  end
end
