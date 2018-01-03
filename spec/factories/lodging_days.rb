FactoryGirl.define do
  factory :lodging_day do
    lodging_room_option # FactoryBot
    sequence(:date_offered) { |n| (10 + n).days.from_now }
  end
end

# == Schema Information
#
# Table name: lodging_days
#
#  id                     :integer          not null, primary key
#  lodging_room_option_id :integer          not null
#  date_offered           :date             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_lodging_days_on_lodging_room_option_id  (lodging_room_option_id)
#
