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

class Judge < ApplicationRecord
  belongs_to :competition
  belongs_to :judge_type
  belongs_to :user

  before_destroy :check_for_scores # must occur before the dependent->destroy

  has_many :scores, -> {order("competitors.position").includes(:competitor) }, dependent: :destroy
  has_many :boundary_scores, -> {order("competitors.position").includes(:competitor) }, dependent: :destroy
  has_many :standard_skill_scores, -> { includes(standard_skill_score_entries: [:standard_skill_routine_entry]) }, dependent: :destroy
  has_many :competitors, -> {order "position"}, through: :competition
  has_many :distance_attempts, -> {order "id DESC"}, dependent: :destroy
  has_many :tie_break_adjustments, dependent: :destroy
  has_many :standard_skill_scores, dependent: :destroy

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

  def num_scored_competitors
    if active_scores.count > 0
      active_scores.count
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
      active_scores.map(&:total).compact
    end
  end

  private

  def active_scores
    if judge_type.event_class == "Standard Skill"
      standard_skill_scores.joins(:competitor).merge(Competitor.active)
    else
      scores.joins(:competitor).merge(Competitor.active)
    end
  end

  # Note, this appears to be duplicated in ability.rb
  def check_for_scores
    if active_scores.count > 0
      errors.add(:base, "cannot delete judge containing a score")
      return false
    end
    if distance_attempts.count > 0
      errors.add(:base, "cannot delete judge containing distance attempts")
      return false
    end
  end
end
