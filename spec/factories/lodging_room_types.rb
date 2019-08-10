FactoryBot.define do
  factory :lodging_room_type do
    lodging # FactoryBot
    sequence(:name) { |n| "Small Room #{n}" }
    sequence(:description) { |n| "lodging type description #{n}" }
  end
end

# == Schema Information
#
# Table name: lodging_room_types
#
#  id                    :bigint           not null, primary key
#  lodging_id            :integer          not null
#  position              :integer
#  name                  :string           not null
#  description           :text
#  visible               :boolean          default(TRUE), not null
#  maximum_available     :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  minimum_duration_days :integer          default(0), not null
#
# Indexes
#
#  index_lodging_room_types_on_lodging_id  (lodging_id)
#
