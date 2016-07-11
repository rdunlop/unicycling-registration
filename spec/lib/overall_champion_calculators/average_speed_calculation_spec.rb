require 'spec_helper'

describe AverageSpeedCalculation do
  let(:entry) { double(distance: 42125) }
  let(:competitor) { double(best_time_in_thousands: 9_000_000) }

  it "calculates in km/hr" do
    result = described_class.calculate_points(competitor, entry)
    expect(result).to eq(16.85)
  end
end
