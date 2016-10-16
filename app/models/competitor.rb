# == Schema Information
#
# Table name: competitors
#
#  id                       :integer          not null, primary key
#  competition_id           :integer
#  position                 :integer
#  custom_name              :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  status                   :integer          default(0)
#  lowest_member_bib_number :integer
#  geared                   :boolean          default(FALSE), not null
#  riding_wheel_size        :integer
#  notes                    :string(255)
#  wave                     :integer
#  riding_crank_size        :integer
#  withdrawn_at             :datetime
#  tier_number              :integer          default(1), not null
#  tier_description         :string
#  age_group_entry_id       :integer
#
# Indexes
#
#  index_competitors_event_category_id                         (competition_id)
#  index_competitors_on_competition_id_and_age_group_entry_id  (competition_id,age_group_entry_id)
#

class Competitor < ApplicationRecord
  include Eligibility
  include Slugify

  has_many :members, dependent: :destroy, inverse_of: :competitor
  has_many :registrants, through: :members
  belongs_to :competition, touch: true, inverse_of: :competitors
  acts_as_restful_list scope: :competition

  has_one :music_file, class_name: "Song", foreign_key: "competitor_id", dependent: :nullify
  has_many :lane_assignments, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :boundary_scores, dependent: :destroy
  has_many :standard_skill_scores, dependent: :destroy
  has_many :distance_attempts, -> { order "distance DESC, id DESC" }, dependent: :destroy
  has_one :tie_break_adjustment, dependent: :destroy
  has_many :time_results, dependent: :destroy
  has_many :start_time_results, -> { merge(TimeResult.start_times) }, class_name: "TimeResult"
  has_many :finish_time_results, -> { merge(TimeResult.finish_times) }, class_name: "TimeResult"
  has_one :external_result, dependent: :destroy
  has_many :results, dependent: :destroy, inverse_of: :competitor
  belongs_to :age_group_entry

  # these are here to allow eager loading/performance optimization
  has_one :age_group_result, -> { where "results.result_type = 'AgeGroup'" }, class_name: "Result"
  has_one :overall_result, -> { where "results.result_type = 'Overall'" }, class_name: "Result"

  accepts_nested_attributes_for :members, allow_destroy: true

  validates :competition_id, presence: true
  validates_associated :members
  validate :must_have_3_members_for_custom_name
  validates :tier_number, presence: true
  validates :tier_number, numericality: { greater_than_or_equal_to: 1, less_than: 10 }

  enum status: [:active, :not_qualified, :dns, :withdrawn, :dnf]
  after_save :touch_members
  after_save :update_age_group_entry

  def touch_members
    members.each do |member|
      member.no_touch_cascade = true
      member.save
    end
  end

  # statuses for use on the sign-ins page
  def self.sign_in_statuses
    statuses.reject{ |stat| stat == "withdrawn"}
  end

  # not all competitor types require a position
  #:numericality => {:only_integer => true, :greater_than => 0}

  delegate :scoring_calculator, to: :competition

  after_initialize :init

  def init
    self.status = :active if status.nil?
  end

  def self.active
    where(status: Competitor.statuses[:active])
  end

  def self.ordered
    reorder(lowest_member_bib_number: :asc)
  end

  def active?
    status == "active"
  end

  def must_have_3_members_for_custom_name
    if (members.size < 3) && !custom_name.blank?
      errors.add(:base, "Must have at least 3 members to specify a custom name")
    end
  end

  def to_s
    name
  end

  def to_s_with_id
    "##{bib_number}-#{self}"
  end

  def first_bib_number
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/first_bib_number") do
      members.first.registrant.bib_number
    end
  end

  # decorator method, which determines how we should present the `member_warnings`
  #
  # returns a class name
  def warning_class
    competition_registrants = competition.signed_up_registrants

    # if status != "active" && status != "withdrawn"
    #   error += "Competitor is #{status}<br>"
    # end

    not_found = false
    members.each do |member|
      # if you are withdrawn, but still signed up, you should be warned
      if status == "withdrawn" && !member.currently_dropped?
        return "competitor_warning"
      elsif member.currently_dropped?
        return "competitor_warning"
      elsif !competition_registrants.include?(member.registrant)
        not_found = true
      end
    end
    return "competitor_not_found" if not_found

    nil
  end

  # Returns a set of 2
  def member_warnings
    competition_registrants = competition.signed_up_registrants
    error = ""
    if status != "active"
      error += "Competitor is #{status}"
      if status == "withdrawn"
        if withdrawn_at.present?
          error += " as of #{withdrawn_at.to_s(:short)}"
        end
      end
      error += "<br>"
    end

    members.each do |member|
      if member.currently_dropped?
        error += "Registrant #{member} has dropped this event from their registration<br>"
      elsif !competition_registrants.include?(member.registrant)
        error += "Registrant #{member} is not in the default list for this competition<br>"
      end
    end
    error.html_safe
  end

  def best_time
    registrants.first.best_time(event)
  end

  def standard_skill_routine
    registrants.first.standard_skill_routine
  end

  delegate :scoring_helper, to: :competition

  def disqualified?
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/#{Result.cache_key_for_set(id)}dq") do
      scoring_helper.competitor_dq?(self)
    end
  end

  def comparable_score
    @comparable_score ||= scoring_calculator.competitor_comparable_result(self)
  end

  def comparable_tie_break_score
    scoring_calculator.competitor_tie_break_comparable_result(self)
  end

  def place
    return 0 if disqualified?
    age_group_result.try(:place)
  end

  def overall_place
    return 0 if disqualified?
    overall_result.try(:place)
  end

  def sorting_place
    return 999 if disqualified? || place.nil?
    place
  end

  def place_formatted
    return scoring_helper.competitor_dq_status_description(self) if disqualified?

    if place == 0 || place.nil?
      return "Unknown"
    else
      place
    end
  end

  def sorting_overall_place
    return 999 if disqualified? || overall_place.nil?
    overall_place
  end

  def overall_place_formatted
    return "DQ" if disqualified?

    if overall_place == 0
      return "Unknown"
    else
      overall_place
    end
  end

  def age_group_entry_description
    return unless members.any?
    return "No Age Group for #{age}-#{gender}" if age_group_entry.nil?

    age_group_entry.to_s
  end

  public

  def has_result?
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/has_result?") do
      scoring_calculator.competitor_has_result?(self)
    end
  end

  def result
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/result") do
      scoring_calculator.competitor_result(self)
    end
  end

  delegate :event, to: :competition

  def member_has_bib_number?(bib_number)
    members.includes(:registrant).where(registrants: {bib_number: bib_number}).count > 0
  end

  def team_name
    custom_name if custom_name.present?
  end

  def name
    comp_name = team_name || registrants_names
    display_eligibility(comp_name, ineligible?)
  end

  def registrants_names
    Rails.cache.fetch("/competitors/#{id}-#{updated_at}/registrants_names") do
      if members.any?
        members.map(&:to_s).join(" - ")
      else
        "(No registrants)"
      end
    end
  end

  def bib_number
    registrants_ids
  end

  def registrants_ids
    Rails.cache.fetch("/competitors/#{id}-#{updated_at}/registrants_ids") do
      if members.any?
        members.map(&:external_id).sort.join(", ")
      else
        "(No registrants)"
      end
    end
  end

  def detailed_name
    if custom_name.present?
      "#{custom_name} (#{registrants_names})"
    else
      registrants_names
    end
  end

  # this field is used for data export
  def export_id
    if members.empty?
      nil
    else
      members.first.external_id
    end
  end

  def age
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/age") do
      if members.empty?
        "(No registrants)"
      else
        ages = members.map(&:age)
        ages.max
      end
    end
  end

  def self.state_or_country_description(usa)
    if usa
      "State"
    else
      "Country"
    end
  end

  def state_or_country(usa)
    if usa
      state
    else
      country
    end
  end

  def state
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/state") do
      if members.empty?
        "(No registrants)"
      else
        # display all states if there are more than 1 registrants
        members.map(&:state).uniq.compact.join(", ")
      end
    end
  end

  def majority_country(input_countries)
    different_countries = input_countries.uniq.compact
    count_of_countries = {}
    different_countries.map{|c| count_of_countries[c] = input_countries.count(c) }

    max_matches = different_countries.map{|c| count_of_countries[c] }.max

    countries_at_max_matches = count_of_countries.select{|_key, value| value == max_matches }.keys

    countries_at_max_matches.sort.join(", ") unless countries_at_max_matches.empty?
  end

  def country
    if members.empty?
      "(No registrants)"
    else
      majority_country(members.map(&:country))
    end
  end

  def heat
    if competition.uses_lane_assignments?
      lane_assignments.first.try(:heat)
    end
  end

  def lane
    lane_assignments.first.try(:lane)
  end

  def gender
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/gender") do
      # all teams should compete against each other, regardless of gender
      num = competition.num_members_per_competitor
      if num == "Two" || num == "Three or more"
        "(n/a)"
      else
        if members.empty?
          "(No registrants)"
        else
          genders = members.map(&:gender)
          # display mixed if there are more than 1 registrants
          if genders.count > 1
            "(mixed)"
          else
            genders.first
          end
        end
      end
    end
  end

  def wheel_size
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/wheel_size_id") do
      if members.empty?
        nil
      else
        members.first.registrant.wheel_size_id_for_event(event)
      end
    end
  end

  def ineligible?
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/ineligible") do
      return true unless active?

      if members.empty?
        false
      else
        eligibles = members.map(&:ineligible?)
        if eligibles.uniq.count > 1
          true # includes both eligible status AND ineligible status
        else
          eligibles.first
        end
      end
    end
  end

  def has_music?
    music_file.present? && music_file.has_file?
  end

  def club
    if members.empty?
      "(No registrants)"
    else
      if members.size > 1
        ""
      else
        members.first.club
      end
    end
  end

  delegate :max_attempted_distance, :has_attempt?, :has_successful_attempt?,
           :max_successful_distance, :max_successful_distance_attempt,
           :distance_attempt_status, :distance_attempt_status_code,
           :acceptable_distance_error, :acceptable_distance?,
           :no_more_jumps?,
           to: :distance_manager

  def distance_manager
    @distance_manager ||= competition.distance_attempt_manager.new(self)
  end

  def is_top?(search_gender)
    return false unless has_result?
    return false if search_gender != gender

    overall_place.to_i > 0 && overall_place.to_i <= 10
  end

  def self.single_selection_text
    "Create Competitor from EACH selected Registrant"
  end

  def self.group_selection_text
    "Create Pair/Group from selected Registrants"
  end

  def self.not_qualified_text
    "Mark these competitors as Not Qualified"
  end

  def details
    res = []
    res << "Geared" if geared
    res << "#{riding_wheel_size}\"" if riding_wheel_size
    res << "#{riding_crank_size}mm" if riding_crank_size
    res << notes unless notes.blank?
    res.join(", ")
  end

  def num_laps
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/#{TimeResult.cache_key_for_set(id)}/num_laps") do
      finish_time_results.first.try(:number_of_laps) || 0
    end
  end

  def competition_start_time
    competition.wave_time_for(wave) || 0
  end

  def best_time_in_thousands
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/#{TimeResult.cache_key_for_set(id)}/best_time_in_thousands") do
      start_times = start_time_results.select(&:active?).map(&:full_time_in_thousands)
      finish_times = finish_time_results.select(&:active?).map(&:full_time_in_thousands)
      TimeResultCalculator.new(start_times, finish_times, competition_start_time, lower_is_better).best_time_in_thousands
    end
  end

  delegate :lower_is_better, to: :scoring_helper

  def update_age_group_entry
    CompetitorAgeGroupEntryUpdateJob.perform_later(id)
  end
end
