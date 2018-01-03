FactoryGirl.define do
  factory :lodging do
    sequence(:name) { |n| "the Lodging #{n}" }
    sequence(:description) { |n| "lodging description #{n}" }
    sequence(:position) { |n| n }
  end
end

# == Schema Information
#
# Table name: lodgings
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  position    :integer
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
