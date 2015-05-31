require 'spec_helper'

describe PlacingPointsCalculator do
  def pts(place, ties)
    described_class.new(place, ties).points
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
end
