# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  long_description  :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  wheel_size_id     :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :age_group_entry do
    age_group_type #FactoryGirl
    sequence(:short_description) { |n| "MyString #{n}" }
    long_description "MyString"
    start_age 1
    end_age 100
    gender "Male"
  end
end
