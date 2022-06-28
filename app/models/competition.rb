# == Schema Information
#
# Table name: competitions
#
#  id                                    :integer          not null, primary key
#  event_id                              :integer
#  name                                  :string
#  created_at                            :datetime
#  updated_at                            :datetime
#  age_group_type_id                     :integer
#  has_experts                           :boolean          default(FALSE), not null
#  scoring_class                         :string
#  start_data_type                       :string
#  end_data_type                         :string
#  uses_lane_assignments                 :boolean          default(FALSE), not null
#  scheduled_completion_at               :datetime
#  awarded                               :boolean          default(FALSE), not null
#  award_title_name                      :string
#  award_subtitle_name                   :string
#  num_members_per_competitor            :string
#  automatic_competitor_creation         :boolean          default(FALSE), not null
#  combined_competition_id               :integer
#  order_finalized                       :boolean          default(FALSE), not null
#  penalty_seconds                       :integer
#  locked_at                             :datetime
#  published_at                          :datetime
#  sign_in_list_enabled                  :boolean          default(FALSE), not null
#  time_entry_columns                    :string           default("minutes_seconds_thousands")
#  import_results_into_other_competition :boolean          default(FALSE), not null
#  base_age_group_type_id                :integer
#  score_ineligible_competitors          :boolean          default(FALSE), not null
#  results_header                        :string
#  hide_max_laps_count                   :boolean          default(FALSE), not null
#
# Indexes
#
#  index_competitions_event_id                    (event_id)
#  index_competitions_on_base_age_group_type_id   (base_age_group_type_id)
#  index_competitions_on_combined_competition_id  (combined_competition_id) UNIQUE
#

class Competition < ApplicationRecord
  include CachedModel
  include Slugify

  resourcify

  belongs_to :base_age_group_type, class_name: "AgeGroupType"
  belongs_to :age_group_type, inverse_of: :competitions
  belongs_to :event, inverse_of: :competitions

  with_options dependent: :destroy do
    has_many :competitors, -> { order "position" }, inverse_of: :competition
    has_many :judges, -> { order "judge_type_id" }
    has_many :competition_sources, foreign_key: "target_competition_id", inverse_of: :target_competition
    has_many :combined_competition_entries
    has_many :published_age_group_entries
    has_many :wave_times, inverse_of: :competition
    has_many :competition_results
    has_many :heat_lane_judge_notes, inverse_of: :competition
    has_many :heat_lane_results, inverse_of: :competition
    has_many :lane_assignments
    has_many :uploaded_files
  end

  belongs_to :combined_competition

  with_options through: :competitors do
    has_many :registrants
    has_many :results
    has_many :distance_attempts
    has_many :time_results
    has_many :external_results
  end

  with_options through: :judges do
    has_many :judge_types
    has_many :scores
  end

  accepts_nested_attributes_for :competition_sources, reject_if: :no_source_selected, allow_destroy: true
  accepts_nested_attributes_for :competitors

  def self.data_recording_types
    ["Two Data Per Line", "One Data Per Line", "Track E-Timer", "Externally Ranked", "Mass Start", "Chip-Timing", "Swiss Track", "UniTimer"]
  end

  validates :start_data_type, :end_data_type, inclusion: { in: data_recording_types, allow_nil: true }

  def self.scoring_classes
    [
      "Freestyle",
      "Artistic Freestyle IUF 2015",
      "Artistic Freestyle IUF 2017",
      "Artistic Freestyle IUF 2019",
      "High/Long",
      "High/Long Preliminary IUF 2015",
      "High/Long Final IUF 2015",
      "High/Long Preliminary IUF 2017",
      "Flatland",
      "Flatland IUF 2017",
      "Street",
      "Street Final",
      "Points Low to High",
      "Points High to Low",
      "Timed Multi-Lap",
      "Longest Time",
      "Shortest Time",
      "Overall Champion",
      "Standard Skill",
      "Shortest Time with Tiers"
    ]
  end

  validates :scoring_class, inclusion: { in: scoring_classes, allow_nil: false }, presence: true

  def self.num_member_options
    ["One", "Two", "Three or more"]
  end
  nilify_blanks only: %i[num_members_per_competitor time_entry_columns start_data_type end_data_type], before: :validation
  validates :num_members_per_competitor, inclusion: { in: num_member_options, allow_nil: true }

  validate :automatic_competitor_creation_only_with_one

  validates :event, presence: true
  validate :published_only_when_locked
  validate :awarded_only_when_published
  validate :award_label_title_checks
  validate :no_competition_sources_when_overall_calculation
  validates :combined_competition, presence: true, if: proc { |f| f.scoring_class == "Overall Champion" }
  validates :combined_competition, absence: true, unless: proc { |f| f.scoring_class == "Overall Champion" }
  validates :results_header, length: { maximum: 100 }

  TIME_ENTRY_COLUMN_TYPES = ["minutes_seconds_thousands", "minutes_seconds_hundreds", "hours_minutes_seconds"].freeze
  validates :time_entry_columns, inclusion: { in: TIME_ENTRY_COLUMN_TYPES }, allow_nil: true

  scope :event_order, -> { includes(:event).order("events.name") }

  validates :name, :award_title_name, presence: true

  delegate  :results_importable, :render_path, :uses_judges, :uses_volunteers, :build_result_from_imported,
            :can_eliminate_judges?, :freestyle_summary?,
            :result_description, :compete_in_order?, :scoring_description,
            :example_result, :imports_times?, :imports_points?, :results_path, :scoring_path, to: :scoring_helper

  after_commit :update_age_group_if_necessary, on: %i[create update]

  # Which columns do we expect to be presented during data-entry?
  # Not yet fully tested/working, see ImportResult:104
  def data_entry_format
    case time_entry_columns
    when "minutes_seconds_thousands"
      OpenStruct.new(hours?: false, thousands?: true, hundreds?: false)
    when "minutes_seconds_hundreds"
      OpenStruct.new(hours?: false, thousands?: false, hundreds?: true)
    when "hours_minutes_seconds"
      OpenStruct.new(hours?: true, thousands?: false, hundreds?: false)
    else
      OpenStruct.new(hours?: false, thousands?: true, hundreds?: false)
    end
  end

  def self.awarded
    where(awarded: true)
  end

  def published?
    published_at.present?
  end

  def locked?
    locked_at.present?
  end

  def unlocked?
    !locked?
  end

  # Caching-related functions

  # Call this when an update occurs to competition which may affect competitors
  def touch_competitors
    touch
    competitors.map(&:touch)
  end

  # Other functions

  def award_title
    res = award_title_name
    res += " #{award_subtitle_name}" if award_subtitle_name.present?
    res
  end

  def to_s
    name
  end

  # should this competition have a start list?
  def start_list?
    uses_lane_assignments? || compete_in_order? || start_data_type == "Mass Start"
  end

  # should this competition display a sign_in list
  def sign_in_list?
    start_data_type == "Mass Start" || sign_in_list_enabled?
  end

  # Public: Is there any data to put on a start list?
  def start_list_present?
    if uses_lane_assignments?
      lane_assignments.any?
    elsif compete_in_order?
      order_finalized?
    elsif start_data_type == "Mass Start"
      wave_numbers.any?
    else
      false
    end
  end

  def heat_numbers
    heats = competitors.map(&:heat).uniq.compact.sort
    if heats.any?
      heats
    else
      lane_assignments.map(&:heat).uniq.compact.sort
    end
  end

  def wave_numbers
    competitors.map(&:wave).uniq.compact.sort
  end

  def end_time_to_s
    scheduled_completion_at&.to_formatted_s(:short)
  end

  def to_s_with_event_class
    to_s + " (#{event_class})"
  end

  def num_assigned_registrants
    Rails.cache.fetch("/competition/#{id}-#{updated_at}/num_assigned_registrants") do
      registrants.count
    end
  end

  def num_competitors
    Rails.cache.fetch("/competition/#{id}-#{updated_at}/num_competitors") do
      competitors.count
    end
  end

  def num_results
    Rails.cache.fetch("/competition/#{id}-#{updated_at}/num_results") do
      competitors.to_a.count { |comp| comp.has_result? }
    end
  end

  def find_competitor_with_bib_number(bib_number)
    competitors.each do |competitor|
      if competitor.member_has_bib_number?(bib_number)
        return competitor
      end
    end
    nil
  end

  def create_competitor_from_registrants(registrants, name, status = "active", wait_for_age_group: false)
    competitor = competitors.build
    competitor.custom_name = name
    competitor.status = status
    registrants.each do |reg|
      member = competitor.members.build
      member.registrant = reg
    end
    if wait_for_age_group
      competitor.wait_for_age_group = true
    end
    competitor.save!
    competitor
  end

  def create_competitors_from_registrants(registrants, status = "active")
    Competitor.transaction do
      registrants.each do |reg|
        create_competitor_from_registrants([reg], nil, status)
      end
    end
  end

  def has_registration_sources?
    competition_sources.any? { |source| source.registration_source? }
  end

  def has_competition_sources?
    competition_sources.any? { |source| source.competition_source? }
  end

  def signed_up_registrants
    @signed_up_registrants ||= competition_sources.inject([]) do |memo, cs|
      memo + cs.signed_up_registrants
    end
  end

  def signed_up_competitors
    @signed_up_competitors ||= competition_sources.inject([]) do |memo, cs|
      memo + cs.signed_up_competitors
    end
  end

  def sorted_competitors
    competitors.active.sort { |a, b| a.bib_number.to_i <=> b.bib_number.to_i }
  end

  def other_eligible_registrants
    if EventConfiguration.singleton.usa?
      Registrant.active.competitor.order(:bib_number) - registrants
    else
      []
    end
  end

  def has_age_group_entry_results?
    age_group_type.present?
  end

  def has_penalty?
    penalty_seconds && penalty_seconds != 0
  end

  def has_num_laps?
    ScoringClass.for(event_class, self)[:num_laps_enabled]
  end

  def max_laps
    Rails.cache.fetch("/competition/#{id}-#{updated_at}/max_laps") do
      time_results.maximum(:number_of_laps)
    end
  end

  def uses_tiers?
    ScoringClass.for(event_class, self)[:tiers_enabled]
  end

  delegate :age_group_entries, to: :age_group_type

  delegate :mixed_gender_age_groups?, to: :age_group_type, allow_nil: true

  def registrant_age_group_data
    registrants.reorder(nil).select(:age, :gender, :wheel_size_id).group(:age, :gender, :wheel_size_id).count(:age).map do |element, count|
      {
        age: element[0],
        gender: element[1],
        wheel_size_id: element[2],
        count: count
      }
    end
  end

  # returns all of the results together, ignoring age-group data
  def results_list
    res = competitors.active.to_a
    res.sort! { |a, b| a.sorting_overall_place <=> b.sorting_overall_place }
  end

  def competitors_with_results
    competitors.active.select(&:has_result?)
  end

  def expert_results_list(gender)
    competitors_with_results.select { |comp| comp.gender == gender }.sort_by(&:sorting_overall_place)
  end

  def results_list_for(ag_entry)
    results = competitors.active.where(age_group_entry: ag_entry).select(&:has_result?)
    results.sort! { |a, b| a.sorting_place <=> b.sorting_place }
  end

  def get_judge(user)
    judges.find_by(user_id: user.id)
  end

  def has_judge(user)
    get_judge(user).present?
  end

  def event_class
    scoring_class
  end

  def wave_time_for(wave_number)
    return if wave_number.nil?

    @wave_time_for ||= []
    return @wave_time_for[wave_number] if @wave_time_for[wave_number]

    @wave_time_for[wave_number] = wave_times.find_by(wave: wave_number).try(:total_seconds)
  end

  def can_calculated_age_group_results?
    case event_class
    when "Shortest Time", "Shortest Time with Tiers"
      true
    when "Longest Time"
      true
    else
      false
    end
  end

  def results_displayer
    # @results_displayer ||= ScoringClass.for(event_class, self)[:results_displayer]
    ResultDisplayer::TimeResult.new(self)
  end

  def exporter
    @exporter ||= ScoringClass.for(event_class, self)[:exporter]
  end

  def scoring_helper
    @scoring_helper ||= ScoringClass.for(event_class, self)[:helper]
  end

  def place_all
    if event_class == "Overall Champion"
      scoring_helper.rebuild_competitors(scoring_calculator.competitor_bib_numbers)
    end
    result_calculator = OrderedResultCalculator.new(self, scoring_helper.lower_is_better)
    if has_age_group_entry_results?
      result_calculator.update_age_group_results
    end
    result_calculator.update_overall_results
  end

  def place_age_group_entry(age_group_entry)
    OrderedResultCalculator.new(self, scoring_helper.lower_is_better).update_age_group_entry_results(age_group_entry)
  end

  # The ScoringCalculator is used to determine the numeric result
  # for each given competitor.
  # Depending on the type of competition, this requires that we look at different
  # data/objects
  # Some, it's as simple as reading their maximum time
  # Some, it requires that we compare the judge results between different places
  #
  # All ScoreCalculators result in a function 'competitor_comparable_result' which
  # provides a numeric/comparable score for the competitor
  def scoring_calculator
    @scoring_calculator ||= ScoringClass.for(event_class, self)[:calculator]
  end

  def judge_score_calculator
    @judge_score_calculator ||= ScoringClass.for(event_class, self)[:judge_score_calculator]
  end

  def high_long_event?
    ScoringClass.for(event_class, self)[:high_long_event?]
  end

  def distance_attempt_manager
    @distance_attempt_manager ||= ScoringClass.for(event_class, self)[:distance_attempt_manager]
  end

  # ###########################
  # SCORE CALC-using functions
  # ###########################

  # COMPETITOR
  def competitor_placing_points(competitor, judge_type, with_ineligible: false)
    sc = scoring_calculator
    if sc.nil?
      0
    else
      sc.total_points_for_judge_type(competitor, judge_type, with_ineligible: with_ineligible)
    end
  end

  # SCORE
  # determining the place points for this score (by-judge)
  def best_distance_attempts
    best_attempts_for_each_competitor = competitors.map(&:max_successful_distance_attempt).compact

    best_attempts_for_each_competitor.sort { |a, b| b.distance <=> a.distance }
  end

  private

  def no_source_selected(attributes)
    attributes['event_category_id'].blank? && attributes['competition_id'].blank?
  end

  def published_only_when_locked
    if published? && !locked?
      errors.add(:base, "Cannot Publish an unlocked Competition")
    end
  end

  def awarded_only_when_published
    if awarded? && !published?
      errors.add(:base, "Cannot Award an un-published Competition")
    end
  end

  def no_competition_sources_when_overall_calculation
    if scoring_class == "Overall Champion" && competition_sources.size.positive?
      errors.add(:competiton_sources_attributes, "unable to specify competition sources when using Overall Champion")
    end
  end

  def automatic_competitor_creation_only_with_one
    if num_members_per_competitor != "One" && automatic_competitor_creation?
      errors.add(:automatic_competitor_creation, "Only valid with one-member-competitor competitions")
    end
  end

  def award_label_title_checks
    # cannot specify subtitle when also specifying an age group
    if age_group_type.present? && award_subtitle_name.present?
      errors.add(:base, "Cannot specify a subtitle AND an age group")
    end

    # has_expert is only allowed when there is also an age group type
    if has_experts? && age_group_type.nil?
      errors.add(:age_group_type_id, "Must specify an age group to also have Experts chosen")
    end

    # requires_age_groups is true for discance and race scoring classes
    if scoring_helper&.requires_age_groups && age_group_type.nil?
      errors.add(:age_group_type_id, "Must specify an age group when using #{scoring_class} scoring class")
    end
  end

  def update_age_group_if_necessary
    return unless previous_changes.key?(:age_group_type_id)

    competitors.each do |competitor|
      competitor.update_age_group_entry
    end
  end
end
