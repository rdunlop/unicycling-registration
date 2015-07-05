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
  include TimePrintable
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

  def competitor_name
    matching_registrant
  end

  def competitor_has_results?
    matching_competitor.has_result? if competitor_exists?
  end

  def disqualified?
    status == "DQ"
  end

  # import the result in the results table, raise an exception on failure
  def import!
    raise "Unable to find registrant" if matching_registrant.nil?

    competitor = matching_competitor
    target_competition = competition
    if competitor.nil?
      matching_competition = matching_registrant.matching_competition_in_event(competition.event)
      if matching_competition
        # another competition with a competitor in the same event exists, use a competitor there
        competitor = matching_registrant.competitors.find_by(competition: matching_competition)
        raise "error finding matching competitor" if competitor.nil?
        target_competition = matching_competition
      end
    end
    if competitor.nil? && EventConfiguration.singleton.can_create_competitors_at_lane_assignment
      # still no competitor, create one in the current event
      registrant = matching_registrant
      target_competition.create_competitor_from_registrants([registrant], nil)
      competitor = target_competition.find_competitor_with_bib_number(bib_number)
    end

    tr = target_competition.build_result_from_imported(self)
    tr.competitor = competitor
    tr.save!
  end

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
