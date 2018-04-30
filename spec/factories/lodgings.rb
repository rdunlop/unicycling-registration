FactoryBot.define do
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
#  id          :bigint(8)        not null, primary key
#  position    :integer
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#
# Indexes
#
#  index_lodgings_on_visible  (visible)
#
