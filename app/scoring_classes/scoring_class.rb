class ScoringClass
  def self.for(scoring_class, competition)
    case scoring_class
    when "Shortest Time with Tiers"
      {
        calculator: ShortestTimeWithTierCalculator.new,
        helper: RaceScoringClass.new(competition)
      }
    when "Shortest Time"
      {
        calculator: RaceResultCalculator.new,
        helper: RaceScoringClass.new(competition)
      }
    when "Longest Time"
      {
        ### XXX this is strange...the determination as to which is the better score is not needed here?
        calculator: RaceResultCalculator.new(false),
        helper: RaceScoringClass.new(competition, false)
      }
    when "Timed Multi-Lap"
      {
        calculator: MultiLapResultCalculator.new,
        helper: RaceScoringClass.new(competition)
      }
    when "Points Low to High"
      {
        calculator: ExternalResultResultCalculator.new,
        helper: PointsScoringClass.new(competition)
      }
    when "Points High to Low"
      {
        calculator: ExternalResultResultCalculator.new,
        helper: PointsScoringClass.new(competition, false)
      }
    when "Freestyle"
      unicon_scoring = !EventConfiguration.singleton.artistic_score_elimination_mode_naucc?
      {
        calculator: ArtisticResultCalculator.new(unicon_scoring),
        # For Freestyle, the judges enter higher scores for better riders
        judge_score_calculator: GenericPlacingPointsCalculator.new(lower_is_better: false),
        helper: ArtisticScoringClass.new(competition)
      }
    when "Artistic Freestyle IUF 2015"
      {
        calculator: ArtisticResultCalculator_2015.new,
        judge_score_calculator: Freestyle_2015_JudgePointsCalculator.new,
        helper: ArtisticScoringClass_2015.new(competition)
      }
    when "Flatland"
      helper = FlatlandScoringClass.new(competition)
      {
        calculator: FlatlandResultCalculator.new,
        judge_score_calculator: GenericPlacingPointsCalculator.new(lower_is_better: helper.lower_is_better),
        helper: helper
      }
    when "Street"
      helper = StreetScoringClass.new(competition)
      {
        calculator: StreetResultCalculator.new,
        judge_score_calculator: GenericPlacingPointsCalculator.new(lower_is_better: helper.lower_is_better),
        helper: helper
      }
    when "Street Final"
      {
        calculator: StreetResultCalculator.new,
        # We know that Street Finals Are ALWAYS lower is better to assign the points
        # But, we want to leave StreetScoringClass as higher_is_better because
        # that way the higher resulting points win.
        judge_score_calculator: GenericPlacingPointsCalculator.new(
          lower_is_better: true,
          points_per_rank: [10, 7, 5, 3, 2, 1]
        ),
        helper: StreetScoringClass.new(competition, false) # this interacts with the judge_score_calculator
      }
    when "High/Long", "High/Long Preliminary IUF 2015", "High/Long Final IUF 2015"
      {
        calculator: DistanceResultCalculator.new,
        helper: DistanceScoringClass.new(competition)
      }
    when "Overall Champion"
      {
        calculator: OverallChampionResultCalculator.new(competition.combined_competition, competition),
        helper: OverallChampionScoringClass.new(competition)
      }
    when "Standard Skill"
      {
        calculator: StandardSkillResultCalculator.new,
        helper: StandardSkillScoringClass.new(competition)
      }
    else
      {
        calculator: nil,
        judge_score_calculator: nil,
        helper: nil
      }
    end
  end
end
