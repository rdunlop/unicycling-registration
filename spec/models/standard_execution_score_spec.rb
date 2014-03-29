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
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'spec_helper'

describe StandardExecutionScore do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
    @competitor = FactoryGirl.create(:event_competitor, :competition => @judge.competition)
    @ssre = FactoryGirl.create(:standard_skill_routine_entry)
  end

  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:standard_execution_score)

    score2 = FactoryGirl.build(:standard_execution_score, :judge => score.judge, 
                                                          :competitor => score.competitor, 
                                                          :standard_skill_routine_entry => score.standard_skill_routine_entry)

    score2.save.should == false

  end

  it "should be able to have 2 different skills scored by the same judge" do
    score = FactoryGirl.create(:standard_execution_score)

    score2 = FactoryGirl.build(:standard_execution_score, :judge => score.judge, 
                                                          :competitor => score.competitor, 
                                                          :standard_skill_routine_entry => FactoryGirl.create(:standard_skill_routine_entry))
    score2.save.should == true
  end

  it "should store the score" do
    score = StandardExecutionScore.new
    score.valid?.should == false
    score.competitor = @competitor
    score.valid?.should == false
    score.judge = @judge
    score.valid?.should == false
    score.standard_skill_routine_entry = @ssre
    score.valid?.should == false
    score.wave = 0
    score.valid?.should == false
    score.line = 0
    score.valid?.should == false
    score.cross = 0
    score.valid?.should == false
    score.circle = 0
    score.valid?.should == true
  end
end
