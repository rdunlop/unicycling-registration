# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_choice do
    event #FactoryGIrl
    sequence(:export_name) {|n| "field_#{n}"}
    cell_type "boolean"
    multiple_values nil
    label "Event_choice chosen"
    position 2
    autocomplete false
  end
end
