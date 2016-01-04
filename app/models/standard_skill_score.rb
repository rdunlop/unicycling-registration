# == Schema Information
#
# Table name: standard_skill_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer          not null
#  judge_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_standard_skill_scores_on_competitor_id               (competitor_id)
#  index_standard_skill_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id)
#

class StandardSkillScore < ActiveRecord::Base
  include Competeable
  belongs_to :judge
  has_many :standard_skill_score_entries, dependent: :destroy, inverse_of: :standard_skill_score

  validates :judge_id, presence: true, uniqueness: {scope: [:competitor_id]}

  accepts_nested_attributes_for :standard_skill_score_entries
end
