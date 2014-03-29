# == Schema Information
#
# Table name: standard_skill_routine_entries
#
#  id                        :integer          not null, primary key
#  standard_skill_routine_id :integer
#  standard_skill_entry_id   :integer
#  position                  :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_skill_routine_entry do
    standard_skill_routine # FactoryGirl
    standard_skill_entry
    position 1
  end
end
