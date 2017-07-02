require 'spec_helper'

RSpec.describe ArtisticResultCalculator_2017 do
  describe "#calculate_weighted_total" do
    let(:totals) do
      [
        {
          type: "Performance",
          total: 10
        },
        {
          type: "Technical",
          total: 10
        },
        {
          type: "Dismount",
          total: 1
        }
      ]
    end

    it "weighs them 45/45/10" do
      expect(described_class.new.calculate_weighted_total(totals)).to be_within(0.1).of(9.1)
    end
  end
end
