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

    it "places an ineligible non-tie as a tie for the next competitor" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(10)).to eq(2)
      expect(@calc.place_next(100, ineligible: true)).to eq(3) # ineligible
      expect(@calc.place_next(1000)).to eq(3) # like-a-tie
      expect(@calc.place_next(10000)).to eq(4) # not 5, because not really a tie
    end

    it "uses the tie-breaking points to break a tie" do
      expect(@calc.place_next(1, tie_break_points: 1)).to eq(1)
      expect(@calc.place_next(1, tie_break_points: 2)).to eq(2)
      expect(@calc.place_next(2, tie_break_points: 1)).to eq(3)
    end

    it "places an ineligible tie as a normal non-place-taking-tie (ineligible second)" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(1, ineligible: true)).to eq(1)
      expect(@calc.place_next(2)).to eq(2)
    end

    it "places an ineligible tie as a normal non-place-taking-tie (ineligible first)" do
      expect(@calc.place_next(1, ineligible: true)).to eq(1)
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(2)).to eq(2)
    end

    it "handles ties when there are no tie-breaker points" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(2)).to eq(2)
      expect(@calc.place_next(2)).to eq(2)
      expect(@calc.place_next(3)).to eq(4)
    end

    it "places 2 ineligibles who come in near each other the same rank" do
      expect(@calc.place_next(1)).to eq(1)
      expect(@calc.place_next(2, ineligible: true)).to eq(2)
      expect(@calc.place_next(3, ineligible: true)).to eq(2)
      expect(@calc.place_next(4)).to eq(2)
      expect(@calc.place_next(5, ineligible: true)).to eq(3)
      expect(@calc.place_next(6)).to eq(3)
      expect(@calc.place_next(7)).to eq(4)
    end

    it "places 2 ineligibles who come in near each other the same ranks" do
      expect(@calc.place_next(1, ineligible: true)).to eq(1)
      expect(@calc.place_next(2, ineligible: true)).to eq(1)
      expect(@calc.place_next(3)).to eq(1)
      expect(@calc.place_next(4)).to eq(2)
      expect(@calc.place_next(4, ineligible: true)).to eq(2)
      expect(@calc.place_next(5, ineligible: true)).to eq(3)
      expect(@calc.place_next(6)).to eq(3)
    end
  end
end
