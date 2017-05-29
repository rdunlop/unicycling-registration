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
#  status_1       :string(255)      default("active")
#  seconds_2      :integer
#  thousands_1    :integer
#  thousands_2    :integer
#  status_2       :string(255)      default("active")
#  is_start_time  :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_two_attempt_entries_ids  (competition_id,is_start_time,id)
#

class TwoAttemptEntry < ApplicationRecord
  include FindsMatchingCompetitor

  validates :competition_id, presence: true
  validates :user_id, :bib_number, presence: true
  validates :minutes_1, :seconds_1, :thousands_1, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
  validates :minutes_2, :seconds_2, :thousands_2, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  nilify_blanks only: %i(status_1 status_2), before: :validation
  validates :status_1, inclusion: { in: TimeResult.status_values, allow_nil: true }
  validates :status_2, inclusion: { in: TimeResult.status_values, allow_nil: true }
  validates :is_start_time, inclusion: { in: [true, false] }

  class TwoAttemptEntryElement
    attr_accessor :minutes, :seconds, :thousands, :status
    include HoursFacade
    include ActiveModel::Model
    validate :results_for_competition

    def disqualified?
      status == "DQ"
    end

    def time_is_present?
      minutes && seconds && thousands
    end

    def build_result
      TimeResult.new(
        minutes: minutes,
        seconds: seconds,
        thousands: thousands,
        status: convert_status
      )
    end

    # convert from ImportStatus statuses [nil, DQ]
    # to TimeresultStatuses ["active", "DQ"]
    def convert_status
      status.nil? ? "active" : status
    end

    private

    def results_for_competition
      return if disqualified?
      unless time_is_present?
        errors.add(:base, "Must enter time or dq")
      end
    end
  end

  belongs_to :user
  belongs_to :competition

  delegate :find_competitor_with_bib_number, to: :competition

  def registrant_name
    Registrant.find_by_bib_number(bib_number)
  end

  # import the result in the results table, raise an exception on failure
  def import!
    # TODO: this should only create a competitor if in the correct "mode"
    competitor = matching_competitor
    if competitor.nil? && EventConfiguration.singleton.can_create_competitors_at_lane_assignment?
      registrant = matching_registrant
      competition.create_competitor_from_registrants([registrant], nil)
      competitor = competition.find_competitor_with_bib_number(bib_number)
    end

    if first_attempt.valid?
      tr1 = first_attempt.build_result
      tr1.competitor = competitor
      tr1.entered_at = created_at
      tr1.entered_by = user
      tr1.is_start_time = is_start_time
      tr1.save!
    end

    if second_attempt.valid?
      tr2 = second_attempt.build_result
      tr2.competitor = competitor
      tr2.entered_at = created_at
      tr2.entered_by = user
      tr2.is_start_time = is_start_time
      tr2.save!
    end
  end

  def first_attempt
    TwoAttemptEntryElement.new(minutes: minutes_1, seconds: seconds_1, thousands: thousands_1, status: status_1)
  end

  def first_attempt=(attempt_params)
    attempt = TwoAttemptEntryElement.new(attempt_params)
    self.minutes_1 = attempt.minutes
    self.seconds_1 = attempt.seconds
    self.thousands_1 = attempt.thousands
    self.status_1 = attempt.status
  end

  def second_attempt
    TwoAttemptEntryElement.new(minutes: minutes_2, seconds: seconds_2, thousands: thousands_2, status: status_2)
  end

  def second_attempt=(attempt_params)
    attempt = TwoAttemptEntryElement.new(attempt_params)
    self.minutes_2 = attempt.minutes
    self.seconds_2 = attempt.seconds
    self.thousands_2 = attempt.thousands
    self.status_2 = attempt.status
  end

  def full_time_1
    TimeResultPresenter.new(minutes_1, seconds_1, thousands_1).full_time
  end

  def full_time_2
    TimeResultPresenter.new(minutes_2, seconds_2, thousands_2).full_time
  end
end
