# == Schema Information
#
# Table name: dismount_scores
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  judge_id       :integer
#  major_dismount :integer
#  minor_dismount :integer
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_boundary_scores_competitor_id                  (competitor_id)
#  index_boundary_scores_judge_id                       (judge_id)
#  index_dismount_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id) UNIQUE
#

class DismountScore < ActiveRecord::Base
  include Judgeable

  validates :major_dismount, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :minor_dismount, presence: true, numericality: {greater_than_or_equal_to: 0}

  def total
    DismountScoreCalculator.new(major_dismount, minor_dismount, num_competitors).calculate
  end

  private

  def num_competitors
    competitor.members.count
  end
end
