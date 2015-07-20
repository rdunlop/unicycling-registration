require 'spec_helper'

describe StreetResultCalculator do
  describe "when calculating the placement points of an event" do
    before(:each) do
      @calc = described_class.new
      @comp1 = double(:competitor, has_result?: true)
      @comp2 = double(:competitor, has_result?: true)
      @comp3 = double(:competitor, has_result?: true)
    end

    describe "and there are 2 judges" do
      before(:each) do
        @score1_1 = double(:score, placing_points: 1)
        @score2_1 = double(:score, placing_points: 2)
        @score3_1 = double(:score, placing_points: 3)

        @score1_2 = double(:score, placing_points: 1)
        @score2_2 = double(:score, placing_points: 3)
        @score3_2 = double(:score, placing_points: 2)

        allow(@comp1).to receive(:scores).and_return([@score1_1, @score1_2])
        allow(@comp2).to receive(:scores).and_return([@score2_1, @score2_2])
        allow(@comp3).to receive(:scores).and_return([@score3_1, @score3_2])
      end

      it "has values for the total placing points, NOT subtracting high and low (only 2 judges)" do
        expect(@calc.competitor_comparable_result(@comp1)).to eq(2)
        expect(@calc.competitor_comparable_result(@comp2)).to eq(5)
        expect(@calc.competitor_comparable_result(@comp3)).to eq(5)
      end

      describe "with a 3rd judge's scores" do
        before(:each) do
          @score1_3 = double(:score, placing_points: 1)
          @score2_3 = double(:score, placing_points: 2)
          @score3_3 = double(:score, placing_points: 3)

          allow(@comp1).to receive(:scores).and_return([@score1_1, @score1_2, @score1_3])
          allow(@comp2).to receive(:scores).and_return([@score2_1, @score2_2, @score2_3])
          allow(@comp3).to receive(:scores).and_return([@score3_1, @score3_2, @score3_3])
        end

        it "has non-zero placing points" do
          expect(@calc.competitor_comparable_result(@comp1)).to eq(3)  # 1,1,1
          expect(@calc.competitor_comparable_result(@comp2)).to eq(7)  # 2,3,2
          expect(@calc.competitor_comparable_result(@comp3)).to eq (8) # 3,2,3
        end
      end
    end
  end
end
