require 'spec_helper'

describe PercentageBasedCalculation do
  context "when I am in first place" do
    specify { expect(described_class.calc_perc_points(best_time: 300, time: 300, base_points: 50, bonus_percentage: 20)).to eq(60) }
  end
  context "when I am in second place" do
    specify { expect(described_class.calc_perc_points(best_time: 300, time: 330, base_points: 50, bonus_percentage: 10)).to be_within(0.1).of(50) }
  end
end
