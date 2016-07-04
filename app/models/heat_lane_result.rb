# == Schema Information
#
# Table name: heat_lane_results
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  heat           :integer          not null
#  lane           :integer          not null
#  status         :string           not null
#  minutes        :integer          not null
#  seconds        :integer          not null
#  thousands      :integer          not null
#  raw_data       :string
#  entered_at     :datetime         not null
#  entered_by_id  :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

class HeatLaneResult < ActiveRecord::Base
  include FindsMatchingCompetitor
  include TracksEnteredBy
  include FindsBibNumberFromHeatLane

  validates :competition_id, :heat, :lane, :status, presence: true
  validates :minutes, :seconds, :thousands, presence: true

  validates :minutes, :seconds, :thousands, numericality: { greater_than_or_equal_to: 0 }
  before_validation :set_time_if_disqualified

  validates :status, inclusion: { in: TimeResult.status_values }

  has_one :time_result, inverse_of: :heat_lane_result
  belongs_to :competition

  scope :heat_lane_order, -> { order(:heat, :lane) }

  after_initialize :init

  def init
    self.status ||= "active"
  end

  def self.heat(heat_number)
    where(heat: heat_number)
  end

  def disqualified?
    status == "DQ"
  end

  # Public: Create a TimeResult entry for this HeatLaneResult
  #
  # Return: nothing
  # Throws an ActiveRecord Exception if unable to save the record
  def import!
    tr = TimeResult.new(
      heat_lane_result: self,
      competitor: matching_competitor,
      minutes: minutes,
      seconds: seconds,
      thousands: thousands,
      status: status,
      is_start_time: false,
      preliminary: false,
      entered_at: entered_at,
      entered_by: entered_by
    )
    tr.save!
  end

  def full_time
    TimeResultPreesnter.new(minutes, seconds, thousands).full_time
  end

  private

  def set_time_if_disqualified
    return unless disqualified?
    self.minutes ||= 0
    self.seconds ||= 0
    self.thousands ||= 0
  end
end
