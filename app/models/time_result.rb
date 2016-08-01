# == Schema Information
#
# Table name: time_results
#
#  id                  :integer          not null, primary key
#  competitor_id       :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string(255)      not null
#  comments            :text
#  comments_by         :string(255)
#  number_of_penalties :integer
#  entered_at          :datetime         not null
#  entered_by_id       :integer          not null
#  preliminary         :boolean
#  heat_lane_result_id :integer
#  status_description  :string
#
# Indexes
#
#  index_time_results_on_competitor_id        (competitor_id)
#  index_time_results_on_heat_lane_result_id  (heat_lane_result_id) UNIQUE
#

class TimeResult < ActiveRecord::Base
  include Competeable
  include Placeable
  include StatusNilWhenEmpty
  include CachedSetModel
  include HoursFacade

  validates :heat_lane_result_id, uniqueness: { message: "Only 1 Import Per Heat/Lane." }, allow_nil: true
  validates :minutes, :seconds, :thousands, numericality: {greater_than_or_equal_to: 0}

  def self.cache_set_field
    :competitor_id
  end

  def self.status_values
    ["active", "DQ", "DNF"]
  end

  validates :status, inclusion: { in: TimeResult.status_values, allow_nil: true }

  belongs_to :entered_by, class_name: 'User', foreign_key: :entered_by_id
  belongs_to :heat_lane_result, inverse_of: :time_result

  validates :is_start_time, inclusion: { in: [true, false] } # because it's a boolean

  scope :fastest_first, -> { order("status DESC, minutes, seconds, thousands") }
  scope :start_times, -> { where(is_start_time: true) }
  scope :finish_times, -> { where(is_start_time: false) }

  after_initialize :init

  def init
    self.minutes = 0 if minutes.nil?
    self.seconds = 0 if seconds.nil?
    self.thousands = 0 if thousands.nil?
  end

  def self.active
    where(status: "active")
  end

  def self.preliminary
    where(preliminary: true)
  end

  def disqualified?
    status == "DQ" || status == "DNF"
  end

  def active?
    !disqualified?
  end

  def as_json(options = {})
    options = {
      except: [:id, :created_at, :updated_at, :competitor_id],
      methods: [:bib_number]
    }
    super(options)
  end

  def bib_number
    competitor.first_bib_number
  end

  def entered_at_to_s
    entered_at.to_formatted_s(:short) if entered_at
  end

  delegate :event, to: :competitor

  def full_time
    return "" if disqualified?

    TimeResultPresenter.from_thousands(full_time_in_thousands).full_time
  end

  def result
    full_time_in_thousands
  end

  def full_time_in_thousands
    (minutes * 60000) + (seconds * 1000) + thousands + penalties_thousands
  end

  private

  def penalties_thousands
    if number_of_penalties && competition.has_penalty?
      number_of_penalties * (competition.penalty_seconds * 1000)
    else
      0
    end
  end
end
