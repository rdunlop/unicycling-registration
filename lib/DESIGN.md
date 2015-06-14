# Comparable Result Calculators

The Goal is to simplify the calculation logic

There should be a single place which creates/stores the ranks for people, based on their scores
There should be a single place which determines their scores

## competitor.comparable_score

Receives:  All necessary information in order to determine the score of a competitor

 Artistic2014
  A competitor's comparable result is their placing points for all judges in a judge type, except the high/low for that judge-type for that competitor.
 Artistic2015
  A Competitor's comparable result is their placing points for any ACTIVE JUDGE, divided by the number of judges
   Note: placing points are created by comparing a judge's results for all competitors....to balance out their scores
 Street Prelim
  A Competitor's Score is the Sum of their rank by each judge, lowest points total is better
 Street Final
  A competitor's score is the sum of their rank, converted into placing points, highest point total is better
 Flat
  A competitor's score is the sum of the scores from each judge, eliminating the high and low scoring judge.
  The Tie breaker is the Sum of Last Trick scores from all judges (or from all judges except the eliminated one?)
 Racing
  A competitor's score is their fastest time for the event.
 Multi Lap
  A competitor's score is the number of laps followed by their time, where the higher number of laps is better, and the lower time is better
 Overall Champion
  A competitor's score is the sum of their placing points from each of the input competitions.
  The tie breaker is the competitor's score from the Tie-break competition
 Distance
  A competitor's score is their longest jump/distance

Outputs: A numeric result for a competitor, which can be compared to other competitors to determine their rank.


## competitor.tie_break_comparable_score

Outputs: A numeric result for a competitor, which can be compared to other competitors' tie_break_comparable_score to determine their rank if tied.

DESIGN:
############### Level 1 #################
- OrderedResultCalculator
 Given the competition (to see 'has_age_group_entry_results?'' and 'competitors'), and 'lower_is_better'
 It will iterate over each competitor
 And will create an overall result for each competitor, using its comparable_score
 And [SOON] will also use its comparable_tie_breaker_score to break ties

 If the competition 'has_age_group_entry_results?' it will also create a result for that competitor at the age-group level (using the same tie-breaker logic too)

 Any Competitor which is "DQ" will be marked DQ
 Any Competitor which is "Ineligible" will be ranked, but their rank will not take that of another competitor

################### Level 2 comparable_score #####################
The ComparableScore and TieBreakerComparableScore are determined by:
 - A "ResultCalculator" class, based on the event_class of the Competition
 The ResultCalculator must have 2 functions 'competitor_comparable_result' and 'competitor_tie_break_comparable_result'
 The result will be a numeric value, which can be used to determine the relative rank of the competitor

When using ExternalResult, TimeResult, or DistanceAttempt, this value is determined by querying competitor for directly-attached data.
When using Judged Scores (ie: Freestyle, Flatland, Street Comp), the score is more difficult to calculate, as it depends on the relative scores of other competitors, since averaging and other calculation must take place.

########### Level 3 ####################
To determine the placing points for a Score, we need to retrieve a PointsCalculator
- Each JudgeType knows the PointsCalculator to use for its 'event_class'

Given the total_score for each competitor for a given judge, it will determine the resulting points to give each competitor for that judge
- Input: Score:total for each competitor for this judge
- Output: placing_points
- Output: Judged Place (the place for this competitor, for this judge)


BUGS: How to deal with Ineligible competitors globally? (does it affect Artistic, etc)
