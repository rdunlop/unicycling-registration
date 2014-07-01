# == Schema Information
#
# Table name: competitions
#
#  id                            :integer          not null, primary key
#  event_id                      :integer
#  name                          :string(255)
#  locked                        :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  age_group_type_id             :integer
#  has_experts                   :boolean          default(FALSE)
#  scoring_class                 :string(255)
#  start_data_type               :string(255)
#  end_data_type                 :string(255)
#  uses_lane_assignments         :boolean          default(FALSE)
#  scheduled_completion_at       :datetime
#  published                     :boolean          default(FALSE)
#  awarded                       :boolean          default(FALSE)
#  published_results_file        :string(255)
#  award_title_name              :string(255)
#  award_subtitle_name           :string(255)
#  published_date                :datetime
#  num_members_per_competitor    :string(255)
#  automatic_competitor_creation :boolean          default(FALSE)
#
# Indexes
#
#  index_competitions_event_id  (event_id)
#

class Competition < ActiveRecord::Base
  include CachedModel

  belongs_to :age_group_type, :inverse_of => :competitions
  belongs_to :event, :inverse_of => :competitions

  has_many :competitors, -> { order "position" }, :dependent => :destroy
  has_many :registrants, :through => :competitors

  has_many :judges, -> { order "judge_type_id" }, :dependent => :destroy
  has_many :judge_types, :through => :judges
  has_many :scores, :through => :judges
  has_many :distance_attempts, :through => :competitors
  has_many :time_results, :through => :competitors
  has_many :external_results, :through => :competitors
  has_many :competition_sources, :foreign_key => "target_competition_id", :inverse_of => :target_competition, :dependent => :destroy
  has_many :combined_competition_entries, dependent: :destroy
  has_many :published_age_group_entries, dependent: :destroy
  has_many :heat_times, dependent: :destroy

  accepts_nested_attributes_for :competition_sources, :reject_if => :no_source_selected, allow_destroy: true
  accepts_nested_attributes_for :competitors
  accepts_nested_attributes_for :heat_times

  has_many :lane_assignments, :dependent => :destroy

  def self.data_recording_types
    ["Two Attempt Distance", "Single Attempt", "Track E-Timer", "Externally Ranked", "Mass Start"]
  end

  before_validation :clear_data_types_of_strings
  validates :start_data_type, :end_data_type, inclusion: { in: self.data_recording_types, allow_nil: true }

  def self.scoring_classes

    ["Freestyle", "High/Long", "Flatland", "Street", "Points Low to High", "Points High to Low", "Timed Multi-Lap", "Longest Time", "Shortest Time"]
  end

  validates :scoring_class, :inclusion => { :in => self.scoring_classes, :allow_nil => false }

  def self.num_member_options
    ["One", "Two", "Three or more"]
  end
  before_validation :clear_num_members_per_compeititor_of_strings
  validates :num_members_per_competitor, inclusion: { in: self.num_member_options, allow_nil: true }

  validate :automatic_competitor_creation_only_with_one

  validates :event_id, :presence => true
  validate :published_only_when_locked
  validate :awarded_only_when_published
  validate :award_label_title_checks

  scope :event_order, -> { includes(:event).order("events.name") }

  validates :name, :award_title_name, :presence => true

  delegate  :results_importable, :render_path, :uses_judges, :build_result_from_imported,
            :build_import_result_from_raw, :score_calculator,
            :result_description, :compete_in_order, :scoring_description,
            :example_result, :imports_times, :results_path, :scoring_path, to: :scoring_helper

  mount_uploader :published_results_file, PdfUploader

  def automatic_competitor_creation_only_with_one
    if num_members_per_competitor != "One" && automatic_competitor_creation
      errors.add(:automatic_competitor_creation, "Only valid with one-member-competitor competitions")
    end
  end

  def award_label_title_checks
    # cannot specify subtitle when also specifying an age group
    if age_group_type.present? && award_subtitle_name.present?
      errors[:base] << "Cannot specify a subtitle AND an age group"
    end

    # has_expert is only allowed when there is also an age group type
    if has_experts && age_group_type.nil?
      errors[:age_group_type_id] << "Must specify an age group to also have Experts chosen"
    end

    if scoring_helper && scoring_helper.requires_age_groups && age_group_type.nil?
      errors[:age_group_type_id] << "Must specify an age group when using #{scoring_class} scoring class"
    end
  end

  def published_only_when_locked
    if published && !locked
      errors[:base] << "Cannot Publish an unlocked Competition"
    end
  end

  def awarded_only_when_published
    if awarded && !published
      errors[:base] << "Cannot Award an un-published Competition"
    end
  end

  def to_s
    self.name
  end

  def end_time_to_s
    scheduled_completion_at.to_formatted_s(:short) if scheduled_completion_at
  end

  def published_date_to_s
    published_date.to_formatted_s(:short) if published_date
  end

  def clear_data_types_of_strings
    self.start_data_type = nil if start_data_type == ""
    self.end_data_type = nil if end_data_type == ""
  end

  def clear_num_members_per_compeititor_of_strings
    self.num_members_per_competitor = nil if num_members_per_competitor == ""
  end

  def to_s_with_event_class
    to_s + " (#{event_class})"
  end

  def no_source_selected(attributes)
    attributes['event_category_id'].blank? && attributes['competition_id'].blank?
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
      competitors.to_a.count{|comp| comp.has_result? }
    end
  end

  def has_results_for_all_competitors?
    num_results > 0 && num_competitors == num_results
  end

  def all_registrants_are_competitors?
    signed_up_registrants.count == num_assigned_registrants
  end

  def find_competitor_with_bib_number(bib_number)
    competitors.each do |competitor|
      if competitor.member_has_bib_number?(bib_number)
        return competitor
      end
    end
    return nil
  end

  def create_competitor_from_registrants(registrants, name, status = "active")
    competitor = competitors.build
    competitor.position = competitors.count + 1
    competitor.custom_name = name
    competitor.status = status
    registrants.each do |reg|
      member = competitor.members.build
      member.registrant = reg
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

  def signed_up_registrants
    res = []
    competition_sources.each do |cs|
      res += cs.signed_up_registrants
    end
    res
  end

  def sorted_competitors
    competitors.sort{|a,b| a.bib_number.to_i <=> b.bib_number.to_i }
  end

  def other_eligible_registrants
    Registrant.active.where(:competitor => true).order(:bib_number) - registrants
  end

  def get_age_group_entry_description(age, gender, wheel_size_id)
    return if age_group_type.nil?

    ag_entry_description = age_group_type.age_group_entry_description(age, gender, wheel_size_id)
    if ag_entry_description.nil?
      "No Age Group for #{age}-#{gender}"
    else
      ag_entry_description
    end
  end

  def has_age_group_entry_results?
    age_group_type.present?
  end

  def age_group_entries
    age_group_type.age_group_entries unless age_group_type.nil?
  end

  def results_list
    results = {}

    if age_group_type.nil?
      # no age groups, put all into a single age group
      results["all"] = competitors.active.to_a
      results["all"].sort!{|a,b| a.sorting_place <=> b.sorting_place}
    else
      age_group_entries.each do |ag_entry|
        results[ag_entry] = results_list_for(ag_entry)
      end
    end

    results
  end

  def competitors_with_results
    competitors.active.select{ |competitor| competitor.has_result? }
  end

  def expert_results_list(gender)
    competitors_with_results.select{|comp| comp.gender == gender}.sort{|a,b| a.sorting_overall_place <=> b.sorting_overall_place }
  end

  def ungeared_expert_results_list(gender)
    competitors_with_results.select{|r| !r.geared? }.sort{|a,b| a.sorting_overall_place <=> b.sorting_overall_place }
  end

  def results_list_for(ag_entry)
    results = competitors.active.select{ |competitor| competitor.has_result? && competitor.age_group_entry == ag_entry }
    results.sort!{|a,b| a.sorting_place <=> b.sorting_place}
  end

  def get_judge(user)
    judges.where({:user_id => user.id}).first
  end

  def has_judge(user)
    get_judge(user).present?
  end

  def event_class
    scoring_class
  end

  def heat_time_for(heat_number)
    configured_heat_time = heat_times.where(heat: heat_number).first
    configured_heat_time.total_seconds if configured_heat_time
  end

  def scoring_helper
    case event_class
    when "Shortest Time"
      @rc ||= RaceScoringClass.new(self)
    when "Longest Time"
      @rc ||= RaceScoringClass.new(self, false)
    when "Timed Multi-Lap"
      @rc ||= MultiLapScoringClass.new(self)
    when "Points Low to High"
      @ers ||= PointsScoringClass.new(self)
    when "Points High to Low"
      @ers ||= PointsScoringClass.new(self, false)
    when "Freestyle"
      @asc ||= ArtisticScoringClass.new(self)
    when "Flatland"
      @fsc ||= FlatlandScoringClass.new(self)
    when "Street"
      @ssc ||= StreetScoringClass.new(self)
    when "High/Long"
      @dsc ||= DistanceScoringClass.new(self)
    else
      nil
    end
  end



  # ###########################
  # SCORE CALC-using functions
  # ###########################

  # COMPETITOR
  def competitor_placing_points(competitor, judge_type)
    sc = score_calculator
    if sc.nil?
      0
    else
      sc.total_points(competitor, judge_type)
    end
  end

  def competitor_total_placing_points(competitor)
    competitor_placing_points(competitor, nil)
  end

  # SCORE
  # determining the place points for this score (by-judge)
  def tied(score)
    score.ties != 0
  end


  # DISTANCE
  def top_distance_attempts(num = 20)
    max_distances = competitors.map(&:max_successful_distance).sort
    if max_distances.count < num
      min_distance = 0
    else
      min_distance = max_distances[-num]
      # if the array is full of 0 (because the competitors return 0 if they haven't any attempts)
      if min_distance == 0
        min_distance = 1
      end
    end

    # select the distance attempts which are in the top-N
    comp = competitors.select {|c| c.max_successful_distance >= min_distance}
    results = comp.map {|c| c.max_successful_distance_attempt}.compact
    results.sort {|a, b| b.distance <=> a.distance }
  end

  def best_distance_attempts
    best_attempts_for_each_competitor = competitors.map(&:max_successful_distance_attempt).compact

    best_attempts_for_each_competitor.sort{ |a,b| b.distance <=> a.distance }
  end
end
