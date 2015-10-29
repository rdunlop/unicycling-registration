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
  validate :formatted_value_is_formatted

  has_paper_trail meta: { registrant_id: :registrant_id }

  belongs_to :event
  belongs_to :registrant, inverse_of: :registrant_best_times, touch: true

  delegate :hint, to: :formatter

  def formatted_value=(new_value)
    @entered_value = new_value
    self.value = formatter.from_string(new_value) if formatter.valid?(entered_value)
  end

  def formatted_value
    entered_value || formatter.to_string(value)
  end

  def to_s
    "Best Time: #{formatted_value}"
  end

  private

  attr_accessor :entered_value

  def formatter
    HourMinuteFormatter
  end

  def formatted_value_is_formatted
    return unless entered_value

    unless formatter.valid?(entered_value)
      errors[:formatted_value] << "Value must match format #{formatter.hint}"
    end
  end
end
