require 'spec_helper'

describe StreetCompScoreCalculator do
  describe "when calculating the placement points of an event" do
    before(:each) do
      @event = FactoryGirl.create(:event) # XXX BUG needs to be street_event
      @event_category = @event.event_categories.first
      @comp1 = FactoryGirl.create(:event_competitor, :event_category => @event_category)
      @comp2 = FactoryGirl.create(:event_competitor, :event_category => @event_category)
      @comp3 = FactoryGirl.create(:event_competitor, :event_category => @event_category)
      @judge = FactoryGirl.create(:judge, :event_category => @event_category)
      @jt = @judge.judge_type
      @score1 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp1, :val_1 => 1, :val_2 => 0, :val_3 => 0, :val_4 => 0)
      @score2 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp2, :val_1 => 5, :val_2 => 0, :val_3 => 0, :val_4 => 0)
      @score3 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp3, :val_1 => 10, :val_2 => 0, :val_3 => 0, :val_4 => 0)
      @calc = StreetCompScoreCalculator.new(@event_category)
    end
    it "should be able to calculate on an invalid score" do
        @calc.calc_place(@comp1.scores.new).should == 0
    end

    it "should set the calc_points according to scores Total" do
      @calc.calc_points(@score1).should == 10
      @calc.calc_points(@score2).should == 7
      @calc.calc_points(@score3).should == 5
    end
    it "should have real total_points (with 1 judge)" do
      @calc.total_points(@score1.competitor).should == 10
      @calc.total_points(@score2.competitor).should == 7
      @calc.total_points(@score3.competitor).should == 5
    end
    it "should calculate the place as empty" do
      @calc.calc_place(@score1).should == 1
      @calc.calc_place(@score2).should == 2
      @calc.calc_place(@score3).should == 3
    end
    it "should be able to 'place' even without enough judges" do
      @calc.place(@score1.competitor).should == 1
      @calc.place(@score2.competitor).should == 2
      @calc.place(@score3.competitor).should == 3
    end
    describe "when there are more than 6 competitors" do
      before(:each) do
        @comp4 = FactoryGirl.create(:event_competitor, :event_category => @event_category)
        @comp5 = FactoryGirl.create(:event_competitor, :event_category => @event_category)
        @comp6 = FactoryGirl.create(:event_competitor, :event_category => @event_category)
        @comp7 = FactoryGirl.create(:event_competitor, :event_category => @event_category)

        @score4 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp4, :val_1 => 7, :val_2 => 0, :val_3 => 0, :val_4 => 0)
        @score5 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp5, :val_1 => 6, :val_2 => 0, :val_3 => 0, :val_4 => 0)
        @score6 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp6, :val_1 => 8, :val_2 => 0, :val_3 => 0, :val_4 => 0)
        @score7 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp7, :val_1 => 3, :val_2 => 0, :val_3 => 0, :val_4 => 0)
      end
      it "can calculate the place for each score" do
        @calc.calc_points(@score1).should == 10 # 10
        @calc.calc_points(@score2).should == 5 # 5
        @calc.calc_points(@score3).should == 0 # 1
        @calc.calc_points(@score4).should == 2 # 3
        @calc.calc_points(@score5).should == 3 # 4
        @calc.calc_points(@score6).should == 1 # 2
        @calc.calc_points(@score7).should == 7 # 7
      end
      it "can place the competitors" do
        @calc.place(@comp1).should == 1
        @calc.place(@comp2).should == 3
        @calc.place(@comp3).should == 7
        @calc.place(@comp4).should == 5
        @calc.place(@comp5).should == 4
        @calc.place(@comp6).should == 6
        @calc.place(@comp7).should == 2
      end
    end

    describe "when calculating ties" do
      before(:each) do
        @score4 = FactoryGirl.create(:score, :judge => @judge, :val_1 => 5, :val_2 => 0, :val_3 => 0, :val_4 => 0)
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
        @judge2 = FactoryGirl.create(:judge, :event_category => @event_category, :judge_type => @jt)
        @score2_1 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score1.competitor, :val_1 => 1, :val_2 => 0, :val_3 => 0, :val_4 => 0)
        @score2_2 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score2.competitor, :val_1 => 10, :val_2 => 0, :val_3 => 0, :val_4 => 0)
        @score2_3 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score3.competitor, :val_1 => 7, :val_2 => 0, :val_3 => 0, :val_4 => 0)
      end
      it "calculates the 2nd judges points correctly" do
        @calc.calc_points(@score2_1).should == 10
        @calc.calc_points(@score2_2).should == 5
        @calc.calc_points(@score2_3).should == 7
      end

      it "determines the highest place ranked" do
        @calc.highest_score(@score1.competitor).should == 10 # judge1
        @calc.highest_score(@score2.competitor).should == 7 # by judge2
        @calc.highest_score(@score3.competitor).should == 7 # by judge1
      end
      it "determines the lowest place ranked" do
        @calc.lowest_score(@score1.competitor).should == 10 # by judge 2
        @calc.lowest_score(@score2.competitor).should == 5 # by judge1
        @calc.lowest_score(@score3.competitor).should == 5 # by judge2
      end

      it "has values for the total placing points, NOT subtracting high and low (only 2 judges)" do
        @calc.total_points(@score1.competitor).should == 20
        @calc.total_points(@score2.competitor).should == 12
        @calc.total_points(@score3.competitor).should == 12
      end

      describe "with a 3rd judge's scores" do
        before(:each) do
          @judge3 = FactoryGirl.create(:judge, :event_category => @event_category, :judge_type => @jt)
          @score3_1 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score1.competitor, :val_1 => 1, :val_2 => 0, :val_3 => 0, :val_4 => 0)
          @score3_2 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score2.competitor, :val_1 => 5, :val_2 => 0, :val_3 => 0, :val_4 => 0)
          @score3_3 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score3.competitor, :val_1 => 6, :val_2 => 0, :val_3 => 0, :val_4 => 0)
        end
        it "has non-zero placing points" do
            @calc.total_points(@score1.competitor).should == 30  # 10,10,10 
            @calc.total_points(@score2.competitor).should == 19   # 7,5,7
            @calc.total_points(@score3.competitor).should == 17   # 5,7,5
        end
        it "converts the place points into place" do
            @calc.place(@score1.competitor).should == 1
            @calc.place(@score2.competitor).should == 2
            @calc.place(@score3.competitor).should == 3
        end
      end
    end
  end
end
