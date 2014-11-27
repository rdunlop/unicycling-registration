# == Schema Information
#
# Table name: standard_skill_routines
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_standard_skill_routines_on_registrant_id  (registrant_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_skill_routine do
    registrant # FactoryGirl
  end
end
