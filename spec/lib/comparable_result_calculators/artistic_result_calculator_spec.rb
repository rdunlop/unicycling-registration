require 'spec_helper'

describe ArtisticResultCalculator do
  before(:each) do
    @competition = FactoryGirl.create(:competition)
    @judge1 = FactoryGirl.create(:judge, competition: @competition)
    @jt = @judge1.judge_type
    @calc = described_class.new
    @comp1 = FactoryGirl.create(:event_competitor, competition: @competition)
    @comp2 = FactoryGirl.create(:event_competitor, competition: @competition)
    @comp3 = FactoryGirl.create(:event_competitor, competition: @competition)
  end
  describe "when calculating the placement points of an event" do
    before(:each) do
      @score1 = double(placing_points: 1, judge_type: @jt)
      @score2 = double(placing_points: 2, judge_type: @jt)
      @score3 = double(placing_points: 3, judge_type: @jt)
    end

    it "should have 0 points for no scores" do
      expect(@calc.total_points(@comp1)).to eq(0.0)
    end

    it "should have total_points of 0 (with 1 judge)" do
      allow(@comp1).to receive(:scores).and_return([@score1])
      expect(@calc.total_points(@comp1)).to eq(0.0)
    end

    it "should have a total_points of 0 (with 2 judge scores)" do
      allow(@comp1).to receive(:scores).and_return([@score1, @score2])
      expect(@calc.total_points(@comp1)).to eq(0.0)
    end

    it "should have the middle score (with 3 judges scores)" do
      allow(@comp1).to receive(:scores).and_return([@score1, @score2, @score3])
      expect(@calc.total_points(@comp1)).to eq(2)
    end

    describe "with technical scores too" do
      before(:each) do
        @tech_jt = FactoryGirl.create(:judge_type, name: "Technical", event_class: @competition.event_class)
        @judge = FactoryGirl.create(:judge, competition: @competition, judge_type: @tech_jt)

        @jt2 = @judge.judge_type

        @score4_1 = double(:score, judge_type: @jt2, placing_points: 4)
        @score5_1 = double(:score, judge_type: @jt2, placing_points: 5)
        @score6_1 = double(:score, judge_type: @jt2, placing_points: 6)
        allow(@comp1).to receive(:scores).and_return([@score1, @score2, @score3, @score4_1, @score5_1, @score6_1])
      end
      # Placing Points:
      #                Pres: 1,2,3  (eliminate 1.3)
      #                Tech: 4,5,6  (eliminate 4,6)

      it "has competitor_tie_break_comparable_result" do
        expect(@calc.competitor_tie_break_comparable_result(@comp1)).to eq(5.0)
      end

      it "has non-zero placing points for correct judge_type" do
        expect(@calc.total_points(@comp1, @jt2)).to eq(5.0)
      end

      it "has total_points for both judge_types, after eliminating high-low from each type" do
        expect(@calc.total_points(@comp1)).to eq(7.0)
      end

      describe "when using NAUCC-style rules" do
        before(:each) do
          @calc = described_class.new(false)
        end

        it "has non-zero placing points for correct judge_type" do
          expect(@calc.total_points(@comp1, @jt)).to eq(2.0)

          expect(@calc.total_points(@comp1, @jt2)).to eq(5.0)
        end

        it "has total_points for both judge_types, after eliminating high-low from all types" do
          expect(@calc.total_points(@comp1)).to eq(14.0)
        end
      end
    end
  end
end
