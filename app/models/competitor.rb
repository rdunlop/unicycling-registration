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
#
# Indexes
#
#  index_competitors_event_category_id  (competition_id)
#

class Competitor < ActiveRecord::Base
  include Eligibility

  has_many :members, dependent: :destroy, inverse_of: :competitor
  has_many :registrants, through: :members
  belongs_to :competition, touch: true, inverse_of: :competitors
  acts_as_restful_list scope: :competition

  has_many :lane_assignments, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :boundary_scores, dependent: :destroy
  has_many :standard_execution_scores, dependent: :destroy
  has_many :standard_difficulty_scores, dependent: :destroy
  has_many :distance_attempts, -> { order "distance DESC, id DESC" }, dependent: :destroy
  has_one :tie_break_adjustment, dependent: :destroy
  has_many :time_results, dependent: :destroy
  has_one :external_result, dependent: :destroy
  has_many :results, dependent: :destroy, inverse_of: :competitor

  # these are here to allow eager loading/performance optimization
  has_many :age_group_results, -> { where "results.result_type = 'AgeGroup'" }, class_name: "Result"
  has_many :overall_results, -> { where "results.result_type = 'Overall'" }, class_name: "Result"

  accepts_nested_attributes_for :members, allow_destroy: true

  validates :competition_id, presence: true
  validates_associated :members
  validate :must_have_3_members_for_custom_name

  enum status: [:active, :not_qualified, :dns, :withdrawn]

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

  def self.ungeared
    where(geared: false)
  end

  def active?
    status == "active"
  end

  def must_have_3_members_for_custom_name
    if (members.size < 3) && !custom_name.blank?
      errors[:base] << "Must have at least 3 members to specify a custom name"
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

  def member_warnings
    competition_registrants = competition.signed_up_registrants
    error = ""
    if status != "active"
      error += "Competitor is #{status}"
    end

    members.each do |member|
      if member.dropped_from_registration?
        error += "Registrant has dropped this event from their registration"
      elsif !competition_registrants.include?(member.registrant)
        error += "Registrant #{member} is not in the default list for this competition"
      end
    end
    error
  end

  def best_time
    registrants.first.registrant_choices.joins(:event_choice).merge(EventChoice.where(cell_type: "best_time", event: event)).first.try(:describe_value)
  end

  def scoring_helper
    competition.scoring_helper
  end

  def disqualified
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
    return 0 if disqualified
    age_group_results.first.try(:place)
  end

  def overall_place
    return 0 if disqualified
    overall_results.first.try(:place)
  end

  def sorting_place
    return 999 if disqualified || place.nil?
    place
  end

  def place_formatted
    return "DQ" if disqualified

    if place == 0 || place.nil?
      return "Unknown"
    else
      place
    end
  end

  def sorting_overall_place
    return 999 if disqualified || overall_place.nil?
    overall_place
  end

  def overall_place_formatted
    return "DQ" if disqualified

    if overall_place == 0
      return "Unknown"
    else
      overall_place
    end
  end

  def age_group_entry_description # XXX combine with the other age_group function
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/age_group_entry_description") do
      competition.get_age_group_entry_description(age, gender, wheel_size) if members.any?
    end
  end

  def age_group_entry
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/age_group_entry") do
      competition.age_group_type.age_group_entry_for(age, gender, wheel_size) if competition.age_group_type.present?
    end
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

  def event
    competition.event
  end

  def member_has_bib_number?(bib_number)
    members.includes(:registrant).where({registrants: {bib_number: bib_number}}).count > 0
  end

  def team_name
    custom_name if custom_name.present?
  end

  def name
    comp_name = team_name || registrants_names
    display_eligibility(comp_name, ineligible)
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
        states = members.map(&:state).uniq.compact
        # display all states if there are more than 1 registrants
        states.join(",") unless states.empty?
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
    else
      read_attribute(:wave)
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

  def ineligible
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/ineligible") do
      return true unless active?

      if members.empty?
        false
      else
        eligibles = members.map(&:ineligible)
        if eligibles.uniq.count > 1
          true # includes both eligible status AND ineligible status
        else
          eligibles.first
        end
      end
    end
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

  # for distance_attempt logic, there are certain 'states' that a competitor can get into
  def double_fault?
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/#{DistanceAttempt.cache_key_for_set(id)}/double_fault") do
      df = false
      if distance_attempts.count > 1
        if distance_attempts[0].fault? && distance_attempts[1].fault? && distance_attempts[0].distance == distance_attempts[1].distance
          df = true
        end
      end

      df
    end
  end

  def distance_attempt_cache_key_base
    "/competitor/#{id}-#{updated_at}/#{DistanceAttempt.cache_key_for_set(id)}/"
  end

  def single_fault?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/single_fault?") do
      if distance_attempts.count > 0
        distance_attempts.first.fault?
      else
        false
      end
    end
  end

  def max_attempted_distance
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/max_attempted_distance") do
      return 0 unless distance_attempts.any?

      distance_attempts.first.distance
    end
  end

  def max_successful_distance
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/max_successful_distance") do
      max_successful_distance_attempt.try(:distance) || 0
    end
  end

  def max_successful_distance_attempt
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/max_successful_distance_attempt") do
      distance_attempts.where(fault: false).first
    end
  end

  def best_distance_attempt
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/best_distance_attempt") do
      # best non-fault result, or, if there are none of those, best result (which will be a fault)
      max_successful_distance_attempt || distance_attempts.first
    end
  end

  def distance_attempt_status_code
    if double_fault?
      "double_fault"
    else
      if single_fault?
        "single_fault"
      else
        "can_attempt"
      end
    end
  end

  def distance_attempt_status
    if distance_attempts.count == 0
      "Not Attempted"
    else
      if double_fault?
        "Finished. Final Score #{max_successful_distance}"
      else
        if single_fault?
          "Fault. Next Distance #{max_attempted_distance}+"
        else
          "Success. Next Distance #{max_attempted_distance + 1}+"
        end
      end
    end
  end

  def is_top?(search_gender)
    return false if !has_result?
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

  def best_time_in_thousands
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/#{TimeResult.cache_key_for_set(id)}/best_time_in_thousands") do
      start_times = start_time_results.map(&:full_time_in_thousands)
      finish_times = finish_time_results.map(&:full_time_in_thousands)

      best_finish_time = 0
      finish_times.each do |ft|
        matching_start_time = start_times.select{ |t| t < ft}.sort.max || (competition_start_time * 1000)
        new_finish_time = ft - matching_start_time
        if best_finish_time == 0 || (new_finish_time == better_time(best_finish_time, new_finish_time))
          best_finish_time = new_finish_time
        end
      end
      best_finish_time
    end
  end

  def num_laps
    Rails.cache.fetch("/competitor/#{id}-#{updated_at}/#{TimeResult.cache_key_for_set(id)}/num_laps") do
      finish_time_results.first.try(:number_of_laps) || 0
    end
  end

  def competition_start_time
    competition.wave_time_for(heat) || 0
  end

  def better_time(time_1, time_2)
    if lower_is_better
      if time_1 < time_2
        time_1
      else
        time_2
      end
    else
      if time_1 < time_2
        time_2
      else
        time_1
      end
    end
  end

  def lower_is_better
    scoring_helper.lower_is_better
  end

  private

  # time result calculations
  def start_time_results
    # time_results.start_times.active
    time_results.select{ |time_result| time_result.status.nil? && time_result.is_start_time }
  end

  def finish_time_results
    # time_results.finish_times.active
    time_results.select{ |time_result| time_result.status.nil? && time_result.is_start_time == false }
  end
end
