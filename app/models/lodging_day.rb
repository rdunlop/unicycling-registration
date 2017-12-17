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

class LodgingDay < ApplicationRecord
  validates :date_offered, uniqueness: { scope: [:lodging_room_option_id] }

  belongs_to :lodging_room_option, inverse_of: :lodging_days

  delegate :to_s, to: :date_offered
end
