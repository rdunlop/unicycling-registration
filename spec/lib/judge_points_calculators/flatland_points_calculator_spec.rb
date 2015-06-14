require 'spec_helper'

describe FlatlandPointsCalculator do
  describe "when calculating the placement points of an event" do
    before(:each) do
      @calc = described_class.new
    end
    describe "when there are multiple competitors with points" do
      let(:all_points) { [10, 5, 4] }

      it "can convert the points into placing points" do
        expect(@calc.judged_place(all_points, 10)).to eq(1)
        expect(@calc.judged_place(all_points, 5)).to eq(2)
        expect(@calc.judged_place(all_points, 4)).to eq(3)
      end

      it "can show the placing points" do
        expect(@calc.judged_points(all_points, 10)).to eq(1)
        expect(@calc.judged_points(all_points, 5)).to eq(2)
        expect(@calc.judged_points(all_points, 4)).to eq(3)
      end
    end

    describe "where there is a tie, the points are split" do
      let(:all_points) { [10, 4, 4, 3] }

      it "should place according to scores, even with ties" do
        expect(@calc.judged_place(all_points, 10)).to eq(1)
        expect(@calc.judged_place(all_points, 4)).to eq(2)
        expect(@calc.judged_place(all_points, 3)).to eq(4)
      end

      it "should split the placing_points" do
        expect(@calc.judged_points(all_points, 10)).to eq(1)
        expect(@calc.judged_points(all_points, 4)).to eq(2.5)
      end
    end
  end
end
