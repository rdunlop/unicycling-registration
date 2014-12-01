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

require 'spec_helper'

describe StandardDifficultyScore do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
    @competitor = FactoryGirl.create(:event_competitor, :competition => @judge.competition)
    @ssre = FactoryGirl.create(:standard_skill_routine_entry)
  end

  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:standard_difficulty_score)

    score2 = FactoryGirl.build(:standard_difficulty_score, :judge => score.judge, 
                                                          :competitor => score.competitor, 
                                                          :standard_skill_routine_entry => score.standard_skill_routine_entry)

    score2.save.should == false
  end

  it "should only allow the devaluation to be either 0, 50 or 100" do
    score = FactoryGirl.create(:standard_difficulty_score)
    score.devaluation = 0
    score.valid?.should == true
    score.devaluation = 1
    score.valid?.should == false
    score.devaluation = 50
    score.valid?.should == true
    score.devaluation = 51
    score.valid?.should == false
    score.devaluation = 100
    score.valid?.should == true
    score.devaluation = 101
    score.valid?.should == false
  end

  it "should be able to have 2 different skills scored by the same judge" do
    score = FactoryGirl.create(:standard_difficulty_score)

    score2 = FactoryGirl.build(:standard_difficulty_score, :judge => score.judge, 
                                                          :competitor => score.competitor, 
                                                          :standard_skill_routine_entry => FactoryGirl.create(:standard_skill_routine_entry))
    score2.save.should == true
  end

  it "should store the score" do
    score = StandardDifficultyScore.new
    score.valid?.should == false
    score.competitor = @competitor
    score.valid?.should == false
    score.judge = @judge
    score.valid?.should == false
    score.standard_skill_routine_entry = @ssre
    score.valid?.should == false
    score.devaluation = 0
    score.valid?.should == true
  end
end
