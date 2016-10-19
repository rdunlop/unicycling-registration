# == Schema Information
#
# Table name: competition_wheel_sizes
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  event_id      :integer
#  wheel_size_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_competition_wheel_sizes_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_competition_wheel_sizes_registrant_id_event_id         (registrant_id,event_id)
#

class CompetitionWheelSize < ApplicationRecord
  belongs_to :registrant, touch: true
  belongs_to :event
  belongs_to :wheel_size

  validates :event, :registrant, :wheel_size, presence: true
  validates :event_id, uniqueness: { scope: [:registrant_id] }
end
