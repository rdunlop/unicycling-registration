require 'spec_helper'

describe StreetCompScoreCalculator do
  describe "when calculating the placement points of an event" do
    before(:each) do
      @competition = FactoryGirl.create(:competition)
      @comp1 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @comp2 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @comp3 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @judge = FactoryGirl.create(:judge, :competition => @competition)
      @jt = @judge.judge_type
      @jt.event_class = "Street"
      @jt.save!
      @score1 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp1, :val_1 => 10)
      @score2 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp2, :val_1 => 5)
      @score3 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp3, :val_1 => 1)
      @calc = StreetCompScoreCalculator.new(@competition)
    end
    it "should be able to calculate places" do
        @calc.place(@comp1).should == 1
        @calc.place(@comp2).should == 2
        @calc.place(@comp3).should == 3
    end

    it "should have real total_points (with 1 judge)" do
      expect(@calc.total_points(@score1.competitor)).to eq()
      expect(@calc.total_points(@score2.competitor)).to == 7
      expect(@calc.total_points(@score3.competitor)).to == 5
    end
    describe "when there are more than 6 competitors" do
      before(:each) do
        @comp4 = FactoryGirl.create(:event_competitor, :competition => @competition)
        @comp5 = FactoryGirl.create(:event_competitor, :competition => @competition)
        @comp6 = FactoryGirl.create(:event_competitor, :competition => @competition)
        @comp7 = FactoryGirl.create(:event_competitor, :competition => @competition)

        @score4 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp4, :val_1 => 3)
        @score5 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp5, :val_1 => 4)
        @score6 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp6, :val_1 => 2)
        @score7 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp7, :val_1 => 7)
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
        @comp4 = FactoryGirl.create(:event_competitor, :competition => @competition)
        @score4 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp4, :val_1 => 5)
      end
      it "should calculate the places" do
        @calc.place(@comp1).should == 1
        @calc.place(@comp2).should == 2
        @calc.place(@comp4).should == 2
        @calc.place(@comp3).should == 4
      end
    end
    describe "and there are 2 judges" do
      before(:each) do
        @judge2 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
        @score2_1 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score1.competitor, :val_1 => 9)
        @score2_2 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score2.competitor, :val_1 => 0)
        @score2_3 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score3.competitor, :val_1 => 3)
      end

      it "has values for the total placing points, NOT subtracting high and low (only 2 judges)" do
        expect(@calc.total_points(@score1.competitor)).to eq(2)
        expect(@calc.total_points(@score2.competitor)).to eq(5)
        expect(@calc.total_points(@score3.competitor)).to eq(5)
      end

      describe "with a 3rd judge's scores" do
        before(:each) do
          @judge3 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
          @score3_1 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score1.competitor, :val_1 => 9)
          @score3_2 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score2.competitor, :val_1 => 5)
          @score3_3 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score3.competitor, :val_1 => 4)
        end
        it "has non-zero placing points" do
            expect(@calc.total_points(@score1.competitor)).to eq(3)  # 1,1,1
            expect(@calc.total_points(@score2.competitor)).to eq(7)  # 2,3,2
            expect(@calc.total_points(@score3.competitor)).to eq (8) # 3,2,3
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
