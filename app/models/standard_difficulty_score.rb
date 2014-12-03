# == Schema Information
#
# Table name: standard_difficulty_scores
#
#  id                              :integer          not null, primary key
#  competitor_id                   :integer
#  standard_skill_routine_entry_id :integer
#  judge_id                        :integer
#  devaluation                     :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#
# Indexes
#
#  standard_diff_judge_routine_comp  (judge_id,standard_skill_routine_entry_id,competitor_id) UNIQUE
#

class StandardDifficultyScore < ActiveRecord::Base
  include Competeable
  belongs_to :judge
  belongs_to :standard_skill_routine_entry

  validates :judge_id, :presence => true, :uniqueness => {:scope => [:standard_skill_routine_entry_id, :competitor_id]}
  validates :standard_skill_routine_entry_id, :presence => true

  validates :devaluation, :presence => true, :inclusion => { :in => [0, 50, 100] }
end
