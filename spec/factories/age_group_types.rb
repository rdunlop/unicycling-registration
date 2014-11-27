# == Schema Information
#
# Table name: age_group_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_age_group_types_on_name  (name) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :age_group_type do
    sequence(:name) {|n| "AgeGroup #{n}"}
  end
end
