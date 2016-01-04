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

require 'spec_helper'

describe StandardSkillScore do
  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:standard_skill_score)

    score2 = FactoryGirl.build(:standard_skill_score, judge: score.judge,
                                                      competitor: score.competitor)

    expect(score2).to be_invalid
  end

  it { is_expected.to validate_presence_of(:competitor_id) }
  it { is_expected.to validate_presence_of(:judge_id) }
end
