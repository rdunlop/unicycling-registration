# == Schema Information
#
# Table name: two_attempt_entries
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  competition_id :integer
#  bib_number     :integer
#  minutes_1      :integer
#  minutes_2      :integer
#  seconds_1      :integer
#  status_1       :string(255)
#  seconds_2      :integer
#  thousands_1    :integer
#  thousands_2    :integer
#  status_2       :string(255)
#  is_start_time  :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

class TwoAttemptEntry < ActiveRecord::Base
  validates :competition_id, :presence => true
  validates :user_id, :bib_number, :presence => true
  validate :results_for_competition
  validates :minutes_1, :seconds_1, :thousands_1, :numericality => {:greater_than_or_equal_to => 0}, allow_nil: true
  validates :minutes_2, :seconds_2, :thousands_2, :numericality => {:greater_than_or_equal_to => 0}, allow_nil: true

  before_validation :clear_status_of_string
  validates :status_1, :inclusion => { :in => TimeResult.status_values, :allow_nil => true }
  validates :status_2, :inclusion => { :in => TimeResult.status_values, :allow_nil => true }

  belongs_to :user
  belongs_to :competition

  delegate :find_competitor_with_bib_number, to: :competition

  def registrant_name
    Registrant.find_by_bib_number(bib_number)
  end

  def has_matching_competitor?
    competition.find_competitor_with_bib_number(bib_number)
  end

  # import the result in the results table, raise an exception on failure
  def import!
    # TODO: this should only create a competitor if in the correct "mode"
    competitor = competition.find_competitor_with_bib_number(bib_number)
    registrant = matching_registrant
    if competitor.nil?
      competition.create_competitor_from_registrants([registrant], nil)
      competitor = competition.find_competitor_with_bib_number(bib_number)
    end

    tr1 = build_result_from_imported(minutes_1, seconds_1, thousands_1, status_1)
    tr1.competitor = competitor
    tr1.is_start_time = is_start_time
    tr1.save!

    if minutes_2
      tr2 = build_result_from_imported(minutes_2, seconds_2, thousands_2, status_2)
      tr2.competitor = competitor
      tr2.is_start_time = is_start_time
      tr2.save!
    end
  end

  def build_result_from_imported(minutes, seconds, thousands, status)
    TimeResult.new(
      minutes: minutes,
      seconds: seconds,
      thousands: thousands,
      status: status
      )
  end

  def full_time_1
    "#{minutes_1}:#{seconds_1}:#{thousands_1}"
  end

  def full_time_2
    "#{minutes_2}:#{seconds_2}:#{thousands_2}"
  end

  private

  def time_is_present?
    minutes_1 && seconds_1 && thousands_1
  end

  def disqualified
    status_1 == "DQ"
  end

  def results_for_competition
    return if disqualified
    unless time_is_present?
      errors.add(:base, "Must enter time or dq")
    end
  end

  def clear_status_of_string
    self.status_1 = nil if status_1 == ""
    self.status_2 = nil if status_2 == ""
  end

  def matching_registrant
    Registrant.find_by(bib_number: bib_number) if bib_number
  end
end
