require 'spec_helper'

describe StreetScore do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
  end
  it "should total the values to create the Total" do
    score = FactoryGirl.build(:street_score)
    score.val_1 = 9.0

    score.Total.should == 9.0
  end
  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:street_score)

    score2 = FactoryGirl.build(:street_score, :judge => score.judge, :competitor => score.competitor)

    score2.save.should == false
  end

  it "should store the judge" do
    score = StreetScore.new
    score.val_1 = 1.0
    score.valid?.should == false
    score.Total.should == 0
    score.competitor_id = 4
    score.valid?.should == false
    score.judge = @judge
    score.valid?.should == true
  end
  it "should validate the bounds of the Values" do
    score = StreetScore.new
    score.val_1 = 1.0
    score.competitor_id = 4
    score.judge = @judge
    score.valid?.should == true
    score.val_1 = 11.0
    score.valid?.should == false
  end
  describe "when the score is based on a judge with judge_type" do
    before(:each) do
        @jt = FactoryGirl.create(:judge_type, :val_1_max => 5, :val_2_max => 6, :val_3_max => 7, :val_4_max => 20)
        @judge = FactoryGirl.create(:judge, :judge_type => @jt)
        @score = StreetScore.new
        @score.val_1 = 1.0
        @score.competitor_id = 4
        @score.judge = @judge
    end
    it "Should validate the bounds of the values when the judge_type specifies different max" do
        score = @score

        score.valid?.should == true
        score.val_1 = 10.0
        score.valid?.should == false
        score.val_1 = 5.0
        score.valid?.should == true
    end
    it "should check each column separately for max" do
        score = @score
        score.valid?.should == true

        score.val_1 = 6.0
        score.valid?.should == false
        score.val_1 = 5.0
        score.valid?.should == true
    end
  end
end
