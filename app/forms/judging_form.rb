class JudgingForm < Reform::Form
  include Composition
  model :score

  property :major_dismounts, from: :val_1, on: :dismount_score
  property :minor_dismounts, from: :val_2, on: :dismount_score
  property :val_2, on: :score
  property :val_3, on: :score
  property :val_4, on: :score

  property :notes, on: :score

  validates :major_dismounts, :minor_dismounts, :val_2, :val_3, :val_4, presence: true

  validates :val_2, :val_3, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 15}
  validates :val_4, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 10}

  def self.build_from_competitor_judge(competitor, judge)
    new(
      dismount_score: dismount_score_for(competitor, judge),
      score: presentation_score_for(competitor, judge))
  end

  private

  def self.dismount_score_for(competitor, judge)
    dismount_judge_type = JudgeType.find_by(name: "Dismount")
    dismount_judge = judge.user.judges.where(judge_type: dismount_judge_type).first
    return nil unless dismount_judge.present?
    score = competitor.scores.where(judge: dismount_judge).first

    unless score
      score = competitor.scores.new
      score.judge = dismount_judge
    end
    score
  end

  def self.presentation_score_for(competitor, judge)
    score = competitor.scores.where(judge: judge).first
    unless score
      score = competitor.scores.new
      score.judge = judge
    end
    score
  end
end
