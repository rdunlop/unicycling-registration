# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  wheel_size_id     :integer
#  position          :integer
#
# Indexes
#
#  age_type_desc                              (age_group_type_id,short_description) UNIQUE
#  index_age_group_entries_age_group_type_id  (age_group_type_id)
#  index_age_group_entries_wheel_size_id      (wheel_size_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :age_group_entry do
    age_group_type #FactoryGirl
    sequence(:short_description) { |n| "MyString #{n}" }
    start_age 1
    end_age 100
    gender "Male"
  end
end
