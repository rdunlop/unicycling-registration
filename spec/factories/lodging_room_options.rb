FactoryGirl.define do
  factory :lodging_room_option do
    lodging_room_type # FactoryGirl
    sequence(:name) { |n| "Small Room #{n}" }
    sequence(:price) { |n| 1000 + n }
    sequence(:position) { |n| n }
  end
end

# == Schema Information
#
# Table name: lodging_room_options
#
#  id                   :integer          not null, primary key
#  lodging_room_type_id :integer          not null
#  position             :integer
#  name                 :string           not null
#  price_cents          :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_lodging_room_options_on_lodging_room_type_id  (lodging_room_type_id)
#
