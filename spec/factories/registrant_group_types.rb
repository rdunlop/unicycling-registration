# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_group_type do
    notes "These be my notes"
    association :source_element, factory: :event
  end
end
