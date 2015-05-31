class ArtisticScoreCalculator_2015
  def initialize(competition)
    @competition = competition # should use this some where in the calculations?
  end

  def update_all_places
    @competition.competitors.each do |competitor|
      new_place  = place(competitor)
      Result.create_new!(competitor, new_place, "Overall")
    end
  end

  # ####################################################################
  #   BY EVENT (all scores, all judges)
  # ####################################################################
  #
  # this should be in "Competitor", but I'm putting here because
  # I don't want to clutter Competitor (which is not always Score-based)
  # inputs:
  #  my_points: points for the current competitor: e.g. 30.1
  # total_points_per_competitor: array of all points: e.g. [40, 30, 30.1, 29, 12, 12]
  # my_tie_break_points: points for me in tie-breaker: e.g. [15]
  # tie_break_points_per_competitor: array of all tie-break points: e.g. [20, 15, 14, 10, 2, 1]
  #
  # result a numeric place
  def new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor)
    my_place = 1
    total_points_per_competitor.each_with_index do |comp_points, index|
      next if comp_points == 0

      if comp_points > my_points
        my_place = my_place + 1
      elsif comp_points == my_points
        if tie_break_points_per_competitor[index] > my_tie_break_points
          my_place = my_place + 1
        end
      end
    end
    my_place
  end

  def place(competitor)
    @place ||= {}
    unless @place[competitor.id].nil?
      return @place[competitor.id]
    end

    return 0 unless competitor.active?

    competitors = competitor.competition.competitors.active

    my_points = total_points(competitor)

    return 0 if my_points == 0

    total_points_per_competitor = competitors.map { |comp| total_points(comp) }

    jt = JudgeType.find_by(name: "Technical", event_class: competitor.competition.event_class) # TODO this should be properly identified
    # XXX only do this if a jt is present?
    my_tie_break_points = total_points(competitor, jt)
    tie_break_points_per_competitor = competitors.map { |comp| total_points(comp, jt) }

    my_place = new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor)

    @place[competitor.id] = my_place
  end

  # Calculate the total number of points for a given competitor
  # judge_type: if specified, limit the results to a given judge_type.
  # NOTE: This function takes into account the "removed scores" by chief judge
  #
  # return a numeric
  def total_points(competitor, judge_type = nil)
    #Rails.cache.fetch("/comp/#{competitor.id}-#{competitor.updated_at}/judge_type/#{judge_type.try(:id)}") do

    if judge_type.nil?
      scores = competitor.scores.joins(:judge).merge(Judge.active)
      # XXX need to gather the results by judge_type, so that I can average them?
    else
      scores = competitor.scores.joins(:judge).where(judges: { judge_type_id: judge_type.id }).merge(Judge.active)
    end

    points = (scores.to_a.sum(&:placing_points) / scores.count.to_f).round(2)
  end
end
