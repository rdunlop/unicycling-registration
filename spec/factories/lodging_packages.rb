FactoryGirl.define do
  factory :lodging_package do
    lodging_room_type
    lodging_room_option
    total_cost 120.30
  end
end

# == Schema Information
#
# Table name: lodging_packages
#
#  id                     :integer          not null, primary key
#  lodging_room_type_id   :integer          not null
#  lodging_room_option_id :integer          not null
#  total_cost_cents       :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_lodging_packages_on_lodging_room_option_id  (lodging_room_option_id)
#  index_lodging_packages_on_lodging_room_type_id    (lodging_room_type_id)
#
