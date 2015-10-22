# == Schema Information
#
# Table name: registrant_best_times
#
#  id              :integer          not null, primary key
#  event_id        :integer          not null
#  registrant_id   :integer          not null
#  source_location :string           not null
#  value           :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_registrant_best_times_on_event_id_and_registrant_id  (event_id,registrant_id) UNIQUE
#  index_registrant_best_times_on_registrant_id               (registrant_id)
#

class RegistrantBestTime < ActiveRecord::Base
  validates :event_id, presence: true, uniqueness: {scope: [:registrant_id]}
  validates :registrant, presence: true

  has_paper_trail meta: { registrant_id: :registrant_id }

  belongs_to :event
  belongs_to :registrant, inverse_of: :registrant_best_times, touch: true

end
