# == Schema Information
#
# Table name: wheel_sizes
#
#  id          :integer          not null, primary key
#  position    :integer
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wheel_size do
    position 1
    description "MyString"

    factory :wheel_size_24 do
      position 3
      description "24\" Wheel"
    end

    factory :wheel_size_20 do
      position 2
      description "20\" Wheel"
    end

    factory :wheel_size_16 do
      position 1
      description "16\" Wheel"
    end
  end
end
