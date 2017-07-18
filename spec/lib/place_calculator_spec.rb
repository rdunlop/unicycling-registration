require 'spec_helper'

describe PlaceCalculator do
  describe "when calculating the placing of a few entries" do
    before(:each) do
      @calc = PlaceCalculator.new
    end

    it "should return DQ as place 0" do
      expect(@calc.place_next(1, dq: true)).to eq("DQ")
    end

    it "should place ascending times as ascending places" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(10)).to eq(2)
      expect(@calc.place_next(100)).to eq(3)
    end
    it "should place multiple times as ties" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(10)).to eq(3)
    end

    it "uses the tie-breaking points to break a tie" do
      expect(@calc.place_next(1, tie_break_points: 1)).to eq(1)
      expect(@calc.place_next(1, tie_break_points: 2)).to eq(2)
      expect(@calc.place_next(2, tie_break_points: 1)).to eq(3)
    end

    it "handles ties when there are no tie-breaker points" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(2)).to eq(2)
      expect(@calc.place_next(2)).to eq(2)
      expect(@calc.place_next(3)).to eq(4)
    end
  end
end
