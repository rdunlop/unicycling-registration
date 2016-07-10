# == Schema Information
#
# Table name: import_results
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  raw_data            :string(255)
#  bib_number          :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  competition_id      :integer
#  points              :decimal(6, 3)
#  details             :string(255)
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string(255)
#  comments            :text
#  comments_by         :string(255)
#  heat                :integer
#  lane                :integer
#  number_of_penalties :integer
#
# Indexes
#
#  index_import_results_on_user_id  (user_id)
#  index_imported_results_user_id   (user_id)
#

class ImportResult < ActiveRecord::Base
  include StatusNilWhenEmpty
  include FindsMatchingCompetitor

  validates :competition_id, presence: true
  validates :user_id, :bib_number, presence: true
  validate :results_for_competition
  validates :minutes, :seconds, :thousands, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  validates :status, inclusion: { in: TimeResult.status_values, allow_nil: true }
  before_validation :set_details_if_blank
  validates :details, presence: true, if: "points?"
  validates :is_start_time, inclusion: { in: [true, false] }

  belongs_to :user
  belongs_to :competition

  default_scope { order(:bib_number) }

  scope :entered_order, -> { reorder(:id) }

  def disqualified?
    status == "DQ" || status == "DNF"
  end

  # Public: Create an ImportResult object.
  # Throws an exception if not valid
  def self.build_and_save_imported_result(raw, raw_data, user, competition, is_start_time)
    status = case raw[4]
             when "DQ"
               "DQ"
             when "DNF"
               "DNF"
             else
               "active"
             end

    num_laps = competition.has_num_laps? ? raw[5] : nil
    ImportResult.create!(
      bib_number: raw[0],
      minutes: raw[1],
      seconds: raw[2],
      thousands: raw[3],
      number_of_laps: num_laps,
      status: status,
      raw_data: raw_data,
      user: user,
      competition: competition,
      is_start_time: is_start_time)
  end

  # import the result in the results table, raise an exception on failure
  def import!
    raise "Unable to find registrant" if matching_registrant.nil?

    competitor = matching_competitor
    target_competition = competition
    if competitor.nil?
      import_into_matching_competitions = false
      if import_into_matching_competitions
        matching_competition = matching_registrant.matching_competition_in_event(competition.event)
        if matching_competition
          # another competition with a competitor in the same event exists, use a competitor there
          competitor = matching_registrant.competitors.find_by(competition: matching_competition)
          raise "error finding matching competitor" if competitor.nil?
          target_competition = matching_competition
        end
      end
    end
    if competitor.nil? && EventConfiguration.singleton.can_create_competitors_at_lane_assignment?
      # still no competitor, create one in the current event
      registrant = matching_registrant
      target_competition.create_competitor_from_registrants([registrant], nil)
      competitor = target_competition.find_competitor_with_bib_number(bib_number)
    end

    tr = target_competition.build_result_from_imported(self)
    tr.competitor = competitor
    tr.save!
  end

  def full_time
    TimeResultPresenter.new(minutes, seconds, thousands).full_time
  end

  # NOT YET fully tested to be working.
  # def minutes
  #   return nil if self[:minutes].blank?
  #   self[:minutes] % 60
  # end

  # def hours
  #   return nil if self[:minutes].blank?
  #   self[:minutes] / 60
  # end

  # def hours=(new_hours)
  #   self.minutes = new_hours.to_i * 60 + (minutes || 0)
  # end

  # def hundreds=(new_hundreds)
  #   self.thousands = new_hundreds.to_i * 10
  # end

  # def hundreds
  #   return nil if thousands.blank?
  #   thousands / 10
  # end

  private

  # determines that the import_result has enough information
  def results_for_competition
    return if disqualified?
    unless time_is_present? || points?
      errors.add(:base, "Must select either time or points")
    end
  end

  def time_is_present?
    minutes && seconds && thousands
  end

  def set_details_if_blank
    if details.blank? && points?
      self.details = "#{points}pts"
    end
  end
end
