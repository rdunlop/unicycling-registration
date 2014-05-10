# == Schema Information
#
# Table name: competitions
#
#  id                :integer          not null, primary key
#  event_id          :integer
#  name              :string(255)
#  locked            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  age_group_type_id :integer
#  has_experts       :boolean          default(FALSE)
#  has_age_groups    :boolean          default(FALSE)
#  scoring_class     :string(255)
#

class Competition < ActiveRecord::Base
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
  has_many :combined_competition_entries
  accepts_nested_attributes_for :competition_sources, :reject_if => :all_blank

  has_many :lane_assignments, :dependent => :destroy
  #has_many :chief_judges, :dependent => :destroy


  def self.scoring_classes
    ["Freestyle", "Distance", "Two Attempt Distance", "Flatland", "Street", "Ranked"]
  end

  validates :scoring_class, :inclusion => { :in => self.scoring_classes, :allow_nil => false }
  validates :event_id, :presence => true

  scope :event_order, -> { includes(:event).order("events.name") }

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }

  def to_s
    event.to_s + " - " + self.name
  end

  def to_s_with_event_class
    to_s + " (#{event_class})"
  end

  def has_non_expert_results
    has_age_groups or ((not has_age_groups) and (not has_experts))
  end

  def has_participant(registrant)
    find_competitor_with_bib_number(registrant.bib_number)
  end

  def find_competitor_with_bib_number(bib_number)
    competitors.each do |competitor|
      if competitor.member_has_bib_number?(bib_number)
        return competitor
      end
    end
    return nil
  end

  def create_competitor_from_registrants(registrants, name)
    competitor = competitors.build
    competitor.position = competitors.count + 1
    competitor.custom_name = name
    registrants.each do |reg|
      member = competitor.members.build
      member.registrant = reg
    end
    if competitor.save
      "Created Group Competitor"
    else
      raise "Unable to create group competitor"
    end
  end

  def create_competitors_from_registrants(registrants)
    num_created = 0
    registrants.each do |reg|
      competitor = competitors.build
      competitor.position = competitors.count + 1
      member = competitor.members.build
      member.registrant = reg
      if competitor.save
        num_created += 1
      else
        raise "Unable to create competitor member for #{reg}"
      end
    end
    "Created #{num_created} competitors"
  end

  def signed_up_registrants
    res = []
    competition_sources.each do |cs|
      res += cs.signed_up_registrants
    end
    res
  end

  def get_age_group_entry_description(age, gender, wheel_size_id)
    ag_entry_description = age_group_type.age_group_entry_description(age, gender, wheel_size_id) unless age_group_type.nil?
    if ag_entry_description.nil?
      "No Age Group for #{age}-#{gender}"
    else
      ag_entry_description
    end
  end

  def age_group_entries
    age_group_type.age_group_entries unless age_group_type.nil?
  end

  def results_list
    results = {}

    if age_group_type.nil?
      # no age groups, put all into a single age group
      results["all"] = competitors
    else
      age_group_entries.each do |ag_entry|
        results[ag_entry] = []
      end

      # sort the competitors by age group
      competitors.each do |competitor|
        next unless competitor.has_result?
        calculated_ag = age_group_type.age_group_entry_for(competitor.age, competitor.gender, competitor.wheel_size)
        results[calculated_ag] << competitor unless calculated_ag.nil?
      end
    end

    #sort the results by place
    results.keys.each do |key|
      results[key].sort!{|a,b| a.place.to_i <=> b.place.to_i}
    end

    results
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

  def render_path
    scoring_helper.render_path
  end

  def scoring_helper
    case event_class
    when "Distance"
      RaceScoringClass.new(self)
    when "Ranked"
      ExternallyRankedScoringClass.new(self)
    when "Freestyle"
      ArtisticScoringClass.new(self)
    when "Flatland"
      FlatlandScoringClass.new(self)
    when "Street"
      StreetScoringClass.new(self)
    when "Two Attempt Distance"
      DistanceScoringClass.new(self)
    else
      nil
    end
  end

  def build_result_from_imported(import_result)
    scoring_helper.build_result_from_imported(import_result)
  end

  def build_import_result_from_raw(raw)
    scoring_helper.build_import_result_from_raw(raw)
  end

  def include_event_name
    scoring_helper.include_event_name
  end

  def uses_lane_assignments
    scoring_helper.uses_lane_assignments
  end

  def score_calculator
    @score_calculator ||= scoring_helper.score_calculator
  end

  def result_description
    scoring_helper.result_description
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
