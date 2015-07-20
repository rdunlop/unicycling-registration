require 'spec_helper'

describe DistanceResultCalculator do
  let(:calc) { described_class.new }

  before do
    @comp = FactoryGirl.build_stubbed(:event_competitor)
  end

  describe "with a tie_breaker result" do
    before :each do
      allow(@comp).to receive(:tie_break_adjustment).and_return(double(tie_break_place: 1))
    end

    it "should have a non-0 tie breaker adjustment value" do
      expect(calc.competitor_tie_break_comparable_result(@comp)).to eq(0.9)
    end
  end

  it "should have a 0 tie_breaker_adjustment" do
    expect(calc.competitor_tie_break_comparable_result(@comp)).to eq(0)
  end
end
