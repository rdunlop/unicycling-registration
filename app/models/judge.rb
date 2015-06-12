# == Schema Information
#
# Table name: judges
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  judge_type_id  :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  status         :string           default("active"), not null
#
# Indexes
#
#  index_judges_event_category_id                                (competition_id)
#  index_judges_judge_type_id                                    (judge_type_id)
#  index_judges_on_judge_type_id_and_competition_id_and_user_id  (judge_type_id,competition_id,user_id) UNIQUE
#  index_judges_user_id                                          (user_id)
#

class Judge < ActiveRecord::Base
  belongs_to :competition
  belongs_to :judge_type
  belongs_to :user

  before_destroy :check_for_scores # must occur before the dependent->destroy

  has_many :scores, -> {order("competitors.position").includes(:competitor) }, dependent: :destroy
  has_many :boundary_scores, -> {order("competitors.position").includes(:competitor) }, dependent: :destroy
  has_many :standard_execution_scores, -> {order("standard_skill_routine_entries.position").includes(:standard_skill_routine_entry)}, dependent: :destroy
  has_many :standard_difficulty_scores, -> {order("standard_skill_routine_entries.position").includes(:standard_skill_routine_entry)}, dependent: :destroy
  has_many :competitors, -> {order "position"}, through: :competition
  has_many :distance_attempts, -> {order "id DESC"}, dependent: :destroy
  has_many :tie_break_adjustments, dependent: :destroy

  accepts_nested_attributes_for :standard_execution_scores
  accepts_nested_attributes_for :standard_difficulty_scores

  validates :competition_id, presence: true
  validates :judge_type_id, presence: true, uniqueness: {scope: [:competition_id, :user_id] }
  validates :user_id, presence: true
  validates :status, inclusion: { in: ["active", "removed"] }

  delegate :event, to: :competition

  def self.active
    where(status: "active")
  end

  def active?
    status == "active"
  end

  # Note, this appears to be duplicated in ability.rb
  def check_for_scores
    if scores.count > 0
      errors[:base] << "cannot delete judge containing a score"
      return false
    end
    if distance_attempts.count > 0
      errors[:base] << "cannot delete judge containing distance attempts"
      return false
    end
  end

  def num_scored_competitors
    if scores.count > 0
      scores.count
    else
      distance_attempts.count("DISTINCT competitor_id")
    end
  end

  def external_id
    user.to_s
  end

  def name
    user.to_s
  end

  def to_s
    name + " (" + judge_type.to_s + ")"
  end

  def score_totals
    Rails.cache.fetch("/judge/#{id}-#{updated_at}/score_totals") do
      scores.map { |s| s.total }
    end
  end

  # retrieve my judged score for the given competitor
  def get_score(competitor)
    scores.where(competitor_id: competitor.id).first
  end

  # Return the calculated total points for this score
  # which will probably be related to the other scores by this judge
  #
  # returns a numeric (probably a fraction)
  def placing_points_for(score)
    return 0 if score.invalid?
    judge_type.score_calculator.judged_points(score_totals, score.total)
  end

  # Return the numeric place of this score, compared to the results of the other scores by this judge
  def judged_place(score)
    return 0 if score.invalid?
    judge_type.score_calculator.judged_place(score_totals, score.total)
  end
end
