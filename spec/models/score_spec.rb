# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Score do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
  end
  it "Must have a value above 0" do
    score = FactoryGirl.build(:score)
    score.val_1 = -1
    score.val_2 = -1
    score.valid?.should == false
  end

  it "should total the values to create the Total" do
    score = FactoryGirl.build(:score)
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0

    score.total.should == 10
  end
  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:score)

    score2 = FactoryGirl.build(:score, :judge => score.judge, :competitor => score.competitor)

    score2.save.should == false
  end

  it "should store the judge" do
    score = Score.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
    score.valid?.should == false
    score.total.should == 0
    score.competitor_id = 4
    score.valid?.should == false
    score.judge = @judge
    score.valid?.should == true
  end
  it "should validate the bounds of the Values" do
    score = Score.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
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
        @score = Score.new
        @score.val_1 = 1.0
        @score.val_2 = 2.0
        @score.val_3 = 3.0
        @score.val_4 = 4.0
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

        score.val_2 = 7.0
        score.valid?.should == false
        score.val_2 = 2.0
        score.valid?.should == true

        score.val_3 = 9.0
        score.valid?.should == false
        score.val_3 = 7.0
        score.valid?.should == true

        score.val_4 = 21.0
        score.valid?.should == false
        score.val_4 = 20.0
        score.valid?.should == true
    end
  end
end
