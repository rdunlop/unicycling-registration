# == Schema Information
#
# Table name: registrant_groups
#
#  id                       :integer          not null, primary key
#  name                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  registrant_group_type_id :integer
#
# Indexes
#
#  index_registrant_groups_on_registrant_group_type_id  (registrant_group_type_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_group do
    sequence(:name) { |n| "MyString #{n}" }
    association :registrant_group_type, factory: :registrant_group_type
  end
end
