require 'spec_helper'

describe GenericPlacingPointsCalculator do
  let(:pts_for_rank) { nil }

  def pts(place, ties)
    described_class.new(points_per_rank: pts_for_rank).points(place, ties)
  end

  it "can convert places into points" do
    expect(pts(1, 0)).to eq(1.0)
    expect(pts(2, 0)).to eq(2.0)
    expect(pts(4, 2)).to eq(5.0)
    expect(pts(7, 0)).to eq(7.0)
    expect(pts(7, 1)).to eq(7.5)
    expect(pts(2, 1)).to eq(2.5)
  end

  it "tracy" do
    expect(pts(2, 2)).to eq(3)
    expect(pts(5, 1)).to eq(5.5)
  end

  describe "when non-standard placing points are given" do
    let(:pts_for_rank) { [10, 7, 5, 3, 2, 1] }

    it "can convert places into points" do
      expect(pts(1, 0)).to eq(10)
      expect(pts(2, 0)).to eq(7)
      expect(pts(2, 1)).to eq(6)
      expect(pts(2, 2)).to eq(5)
    end
  end

  let(:calc) { described_class.new }

  describe "when there are multiple competitors with points" do
    let(:all_points) { [10, 5, 1] }

    it "can convert the points into placing points" do
      expect(calc.judged_place(all_points, 10)).to eq(1)
      expect(calc.judged_place(all_points, 5)).to eq(2)
      expect(calc.judged_place(all_points, 4)).to eq(3)
    end

    it "can show the placing points" do
      expect(calc.judged_points(all_points, 10)).to eq(1)
      expect(calc.judged_points(all_points, 5)).to eq(2)
      expect(calc.judged_points(all_points, 1)).to eq(3)
    end
  end

  describe "when there are more than 6 competitors" do
    let(:all_points) { [10, 5, 1, 3, 4, 2, 7] }

    it "can convert the points into placing points" do
      expect(calc.judged_place(all_points, 10)).to eq(1)
      expect(calc.judged_place(all_points, 5)).to eq(3)
      expect(calc.judged_place(all_points, 1)).to eq(7)
      expect(calc.judged_place(all_points, 3)).to eq(5)
      expect(calc.judged_place(all_points, 4)).to eq(4)
      expect(calc.judged_place(all_points, 2)).to eq(6)
      expect(calc.judged_place(all_points, 7)).to eq(2)
    end
  end

  describe "where there is a tie, the points are split" do
    let(:all_points) { [10, 4, 4, 3] }

    it "should place according to scores, even with ties" do
      expect(calc.judged_place(all_points, 10)).to eq(1)
      expect(calc.judged_place(all_points, 4)).to eq(2)
      expect(calc.judged_place(all_points, 3)).to eq(4)
    end

    it "should split the placing_points" do
      expect(calc.judged_points(all_points, 10)).to eq(1)
      expect(calc.judged_points(all_points, 4)).to eq(2.5)
    end
  end
end
