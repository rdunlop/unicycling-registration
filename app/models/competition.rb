class Competition < ActiveRecord::Base
  belongs_to :age_group_type, :inverse_of => :competitions
  belongs_to :event, :inverse_of => :competitions
  has_one :event_category, :dependent => :nullify

  has_many :competitors, :dependent => :destroy, :order => "position"
  has_many :registrants, :through => :competitors

  has_many :judges, :dependent => :destroy, :order => "judge_type_id"
  has_many :judge_types, :through => :judges
  has_many :scores, :through => :judges
  has_many :distance_attempts, :through => :competitors
  has_many :time_results, :through => :competitors
  has_many :external_results, :through => :competitors

  has_many :lane_assignments, :dependent => :destroy
  #has_many :chief_judges, :dependent => :destroy

  scope :event_order, includes(:event).order("events.name")

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

  def find_competitor_with_bib_number(bib_number)
    competitors.each do |competitor|
      if competitor.member_has_bib_number?(bib_number)
        return competitor
      end
    end
    return nil
  end

  def create_competitors_from_registrants(registrants)
    num_created = 0
    registrants.each do |reg|
      competitor = competitors.build
      competitor.position = competitors.count + 1
      competitor.save
      member = competitor.members.build
      member.registrant = reg
      if member.save
        num_created += 1
      end
    end
    "Created #{num_created} competitors"
  end

  def signed_up_registrants
    event_category.signed_up_registrants
  end

  def get_age_group_entry_description(age, gender, wheel_size_id)
    ag_entry_description = determine_age_group_type.try(:age_group_entry_description, age, gender, wheel_size_id)
    if ag_entry_description.nil?
      "No Age Group for #{age}-#{gender}"
    else
      ag_entry_description
    end
  end

  # remains public so that we can easily iterate over the group-entries
  def determine_age_group_type
    if age_group_type.nil?
      unless event_category.nil?
        return event_category.age_group_type
      else
        nil
      end
    else
      age_group_type
    end
  end

  def age_group_entries
    determine_age_group_type.try(:age_group_entries)
  end

  def results_list
    @agt = determine_age_group_type
    @results_list = {}
    if @agt.nil?
      # no age groups, put all into a single age group
      @results_list["all"] = competitors
    else
      @age_group_entries = age_group_entries
      @age_group_entries.each do |ag_entry|
        @results_list[ag_entry] = []
      end

      # sort the competitors by age group
      competitors.each do |competitor|
        next unless competitor.has_result?
        calculated_ag = @agt.age_group_entry_for(competitor.age, competitor.gender, competitor.wheel_size)
        @results_list[calculated_ag] << competitor unless calculated_ag.nil?
      end
    end

    #sort the results by place
    @results_list.keys.each do |key|
      @results_list[key].sort!{|a,b| a.place.to_i <=> b.place.to_i}
    end

    @results_list
  end

  def get_judge(user)
    return judges.where({:user_id => user.id}).first
  end

  def has_judge(user)
    return !get_judge(user).nil?
  end

  def event_class
    event.event_class
  end

  def score_calculator
    unless @score_calculator.nil?
      return @score_calculator
    end

    # XXX repetative code...should be able to eliminate/refactor?
    @config = { unicon_scoring: false }
    unicon_scoring = false

    # Fancy Trick: "#{event_class}ScoreCalculator".classify.new(self)
    case event_class
    when "Freestyle"
      @score_calculator = ArtisticScoreCalculator.new(self, unicon_scoring)
    when 'Flatland'
      @score_calculator = FlatlandScoreCalculator.new(self)
    when 'Street'
      @score_calculator = StreetCompScoreCalculator.new(self)
    when "Two Attempt Distance"
      @score_calculator = DistanceCalculator.new(self)
    when "Distance"
      @score_calculator = RaceCalculator.new(self)
    when "Ranked"
      @score_calculator = ExternallyRankedCalculator.new(self)
    end
  end

  def result_description
    case event_class
    when "Two Attempt Distance"
      "Distance"
    when "Distance"
      "Time"
    when "Ranked"
      "Score"
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
  def score_judged_points(score)
    score_calculator.calc_points(score)
  end

  def score_judged_place(score)
    place = score_calculator.calc_place(score)
    if score.Total.nil?
      ""
    else
      place.to_s
    end
  end

  def tied(score)
    if score_calculator.ties(score) > 1
      true
    else
      false
    end
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
    results = comp.map {|c| c.max_successful_distance_attempt}
    results.delete(nil)
    results.sort {|a, b| b.distance <=> a.distance }
  end
  def best_distance_attempts
    best_attempts_for_each_competitor = competitors.map(&:max_successful_distance_attempt)
    best_attempts_for_each_competitor.delete(nil)

    best_attempts_for_each_competitor.sort{ |a,b| b.distance <=> a.distance }
  end
end
