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
#
# Indexes
#
#  index_time_results_on_competitor_id  (competitor_id)
#

class TimeResult < ActiveRecord::Base
  include Competeable
  include Placeable
  include StatusNilWhenEmpty
  include CachedSetModel

  validates :minutes, :seconds, :thousands, numericality: {greater_than_or_equal_to: 0}

  def self.cache_set_field
    :competitor_id
  end

  def self.status_values
    ["active", "DQ"]
  end

  validates :status, inclusion: { in: TimeResult.status_values, allow_nil: true }

  belongs_to :entered_by, class_name: 'User', foreign_key: :entered_by_id

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

  def self.build_and_save_imported_result(raw, raw_data, user, competition, is_start_time)
    dq = (raw[4] == "DQ")
    ImportResult.create(
      bib_number: raw[0],
      minutes: raw[1],
      seconds: raw[2],
      thousands: raw[3],
      status: dq ? "DQ" : "active",
      raw_data: raw_data,
      user: user,
      competition: competition,
      is_start_time: is_start_time)
  end

  def disqualified?
    status == "DQ"
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

    TimeResultPresenter.new(full_time_in_thousands).full_time
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
