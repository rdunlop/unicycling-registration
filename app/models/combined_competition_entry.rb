# == Schema Information
#
# Table name: combined_competition_entries
#
#  id                      :integer          not null, primary key
#  combined_competition_id :integer
#  abbreviation            :string
#  tie_breaker             :boolean          default(FALSE), not null
#  points_1                :integer
#  points_2                :integer
#  points_3                :integer
#  points_4                :integer
#  points_5                :integer
#  points_6                :integer
#  points_7                :integer
#  points_8                :integer
#  points_9                :integer
#  points_10               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  competition_id          :integer
#  base_points             :integer
#  distance                :integer
#  points_11               :integer
#  points_12               :integer
#  points_13               :integer
#  points_14               :integer
#  points_15               :integer
#

class CombinedCompetitionEntry < ApplicationRecord
  belongs_to :combined_competition, touch: true
  belongs_to :competition

  validates :combined_competition, :abbreviation, presence: true
  validates :competition, presence: true

  validates :base_points, presence: true, if: :is_percentage_based?
  validates :distance, presence: true, if: :is_average_speed_based?

  validates :tie_breaker, inclusion: { in: [true, false] }

  def to_s
    abbreviation + (tie_breaker? ? "*" : "")
  end

  def competitors(gender)
    @competitors ||= {}
    @competitors[gender] ||= competition.results.overall.includes(competitor: %i[age_group_result overall_result competition]).where("place > 0").map(&:competitor).select { |comp| comp.gender == gender }
  end

  def male_competitors
    competitors("Male")
  end

  def female_competitors
    competitors("Female")
  end

  def bonus_for_place(place)
    if combined_competition.range_of_places.include?(place)
      send("points_#{place}").to_i
    else
      0
    end
  end

  def best_time_in_thousands(gender)
    @best_time_in_thousands ||= {}
    @best_time_in_thousands[gender] ||= determine_best_time_in_thousands(gender)
  end

  def determine_best_time_in_thousands(gender)
    first_place_results = competition.results.includes(:competitor).overall.where(place: 1)
    gender_comp = first_place_results.map(&:competitor).find { |comp| comp.gender == gender }
    gender_comp.try(:comparable_score)
  end

  private

  def is_percentage_based?
    combined_competition.percentage_based_calculations?
  end

  def is_average_speed_based?
    combined_competition.average_speed_calculation?
  end

  def requires_points?
    combined_competition.requires_per_place_points?
  end
end
