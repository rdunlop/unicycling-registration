require 'spec_helper'

describe FlatlandScoreCalculator do
  describe "when calculating the placement points of an event" do
    before(:each) do
      @competition = FactoryGirl.create(:competition)
      @comp1 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @comp2 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @comp3 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @judge = FactoryGirl.create(:judge, :competition => @competition)
      @jt = @judge.judge_type
      @score1 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp1, :val_1 => 10, :val_2 => 0, :val_3 => 0, :val_4 => 1)
      @score2 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp2, :val_1 => 5, :val_2 => 0, :val_3 => 0, :val_4 => 1)
      @score3 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp3, :val_1 => 0, :val_2 => 0, :val_3 => 0, :val_4 => 1)
      @calc = FlatlandScoreCalculator.new(@competition)
    end
    it "should be able to calculate on an invalid score" do
        @calc.calc_place(@comp1.scores.new).should == 0
    end

    it "should set the calc_placing_points according to scores Total" do
      @calc.calc_placing_points(@score1).should == 11
      @calc.calc_placing_points(@score2).should == 6
      @calc.calc_placing_points(@score3).should == 1
    end
    it "should have total_points of 0 (with 1 judge)" do
      @calc.total_points(@score1.competitor).should == 0.0
      @calc.total_points(@score2.competitor).should == 0.0
      @calc.total_points(@score3.competitor).should == 0.0
    end
    it "should calculate the place as empty" do
      @calc.calc_place(@score1).should == 1
      @calc.calc_place(@score2).should == 2
      @calc.calc_place(@score3).should == 3
    end
    it "should be able to 'place' even without enough judges" do
      @calc.place(@score1.competitor).should == 1
      @calc.place(@score2.competitor).should == 1
      @calc.place(@score3.competitor).should == 1
    end

    describe "when calculating ties" do
      before(:each) do
        @score4 = FactoryGirl.create(:score, :judge => @judge, :val_1 => 5, :val_2 => 0, :val_3 => 0, :val_4 => 1)
      end
      it "gives both 2nd places 2.5 points" do
        @calc.ties(@score2).should == 2
      end
      it "should calculate the places" do
        @calc.calc_place(@score1).should == 1
        @calc.calc_place(@score2).should == 2
        @calc.calc_place(@score4).should == 2
        @calc.calc_place(@score3).should == 4
      end
    end
    describe "and there are 2 judges" do
      before(:each) do
        @judge2 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
        @score2_1 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score1.competitor, :val_1 => 9, :val_2 => 0, :val_3 => 0, :val_4 => 1)
        @score2_2 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score2.competitor, :val_1 => 0, :val_2 => 0, :val_3 => 0, :val_4 => 1)
        @score2_3 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score3.competitor, :val_1 => 3, :val_2 => 0, :val_3 => 0, :val_4 => 1)
      end
      it "calculates the 2nd judges points correctly" do
        @calc.calc_placing_points(@score2_1).should == 10
        @calc.calc_placing_points(@score2_2).should == 1
        @calc.calc_placing_points(@score2_3).should == 4
      end

      it "determines the highest place ranked" do
        @calc.highest_score(@score1.competitor).should == 11 # judge1
        @calc.highest_score(@score2.competitor).should == 6 # by judge1
        @calc.highest_score(@score3.competitor).should == 4 # by judge2
      end
      it "determines the lowest place ranked" do
        @calc.lowest_score(@score1.competitor).should == 10 # by judge 2
        @calc.lowest_score(@score2.competitor).should == 1 # by judge2
        @calc.lowest_score(@score3.competitor).should == 1 # by judge1
      end

      it "has 0.0 for the total placing points, after subtracting high and low (only 2 judges)" do
        @calc.total_points(@score1.competitor).should == 0.0
        @calc.total_points(@score2.competitor).should == 0.0
        @calc.total_points(@score3.competitor).should == 0.0
      end

      describe "with a 3rd judge's scores" do
        before(:each) do
          @judge3 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
          @score3_1 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score1.competitor, :val_1 => 9, :val_2 => 0, :val_3 => 0, :val_4 => 1)
          @score3_2 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score2.competitor, :val_1 => 4, :val_2 => 0, :val_3 => 0, :val_4 => 1)
          @score3_3 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score3.competitor, :val_1 => 4, :val_2 => 0, :val_3 => 0, :val_4 => 1)
        end
        it "has non-zero placing points" do
            @calc.total_points(@score1.competitor).should == 10  # 11,10,10 (remain: 10)
            @calc.total_points(@score2.competitor).should == 5   # 6,1,5 (remain: 5)
            @calc.total_points(@score3.competitor).should == 4   # 1,4,5 (remain: 4)
        end
        it "has non-zero placing points for correct judge_type" do
            @calc.total_points(@score1.competitor, @judge3.judge_type).should == 10
            @calc.total_points(@score2.competitor, @judge3.judge_type).should == 5
            @calc.total_points(@score3.competitor, @judge3.judge_type).should == 4
        end
        it "converts the place points into place" do
            @calc.place(@score1.competitor).should == 1
            @calc.place(@score2.competitor).should == 2
            @calc.place(@score3.competitor).should == 3
        end
        describe "when checking a tie" do
            before(:each) do
                @score3_2.val_1 = 2
                @score3_2.val_4 = 2
                @score3_2.save!
            end
            it "should have a tie now" do
              @calc.total_points(@score1.competitor, @judge3.judge_type).should == 10
              @calc.total_points(@score2.competitor, @judge3.judge_type).should == 4
              @calc.total_points(@score3.competitor, @judge3.judge_type).should == 4
            end
            it "should drop the high-low of the 'Total'" do
              Score.count.should == 9
              @calc.total_last_trick_points(@score1.competitor, nil).should == 1
              @calc.total_last_trick_points(@score2.competitor, nil).should == 2
              @calc.total_last_trick_points(@score3.competitor, nil).should == 1
              Score.count.should == 9
            end
            it "should break the tie when calculating place, according to val_4" do
              @calc.place(@score1.competitor).should == 1
              @calc.place(@score2.competitor).should == 2
              @calc.place(@score3.competitor).should == 3
            end
        end
      end
    end
  end
end
