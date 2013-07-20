class Competition < ActiveRecord::Base
  attr_accessible :name, :event_id, :locked

  belongs_to :event, :inverse_of => :competitions

  has_many :competitors, :dependent => :destroy, :order => "position"
  has_many :registrants, :through => :competitors

  has_many :judges, :dependent => :destroy, :order => "judge_type_id"
  has_many :judge_types, :through => :judges
  has_many :scores, :through => :judges
  has_many :distance_attempts, :through => :competitors
  has_many :time_results, :through => :judges
  #has_many :chief_judges, :dependent => :destroy

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }

  def to_s
    event.to_s + " - " + self.name
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
    if event_class == "Freestyle"
      @score_calculator = ArtisticScoreCalculator.new(self, unicon_scoring)
    elsif event_class == 'Flatland'
      @score_calculator = FlatlandScoreCalculator.new(self)
    elsif event_class == 'Street'
      @score_calculator = StreetCompScoreCalculator.new(self)
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

  def competitor_place(competitor)
    sc = score_calculator
    if sc.nil?
      0
    else
      sc.place(competitor)
    end
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
    best_attempts_for_each_competitor
  end
end
