# == Schema Information
#
# Table name: standard_execution_scores
#
#  id                              :integer          not null, primary key
#  competitor_id                   :integer
#  standard_skill_routine_entry_id :integer
#  judge_id                        :integer
#  wave                            :integer
#  line                            :integer
#  cross                           :integer
#  circle                          :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#
# Indexes
#
#  standard_exec_judge_routine_comp  (judge_id,standard_skill_routine_entry_id,competitor_id) UNIQUE
#

require 'spec_helper'

describe StandardExecutionScore do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
    @competitor = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @ssre = FactoryGirl.create(:standard_skill_routine_entry)
  end

  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:standard_execution_score)

    score2 = FactoryGirl.build(:standard_execution_score, judge: score.judge,
                                                          competitor: score.competitor,
                                                          standard_skill_routine_entry: score.standard_skill_routine_entry)

    expect(score2.save).to eq(false)
  end

  it "should be able to have 2 different skills scored by the same judge" do
    score = FactoryGirl.create(:standard_execution_score)

    score2 = FactoryGirl.build(:standard_execution_score, judge: score.judge,
                                                          competitor: score.competitor,
                                                          standard_skill_routine_entry: FactoryGirl.create(:standard_skill_routine_entry))
    expect(score2.save).to eq(true)
  end

  it "should store the score" do
    score = StandardExecutionScore.new
    expect(score.valid?).to eq(false)
    score.competitor = @competitor
    expect(score.valid?).to eq(false)
    score.judge = @judge
    expect(score.valid?).to eq(false)
    score.standard_skill_routine_entry = @ssre
    expect(score.valid?).to eq(false)
    score.wave = 0
    expect(score.valid?).to eq(false)
    score.line = 0
    expect(score.valid?).to eq(false)
    score.cross = 0
    expect(score.valid?).to eq(false)
    score.circle = 0
    expect(score.valid?).to eq(true)
  end
end
