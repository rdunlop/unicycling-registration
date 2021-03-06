require 'spec_helper'

describe DistanceResultCalculator do
  let(:calc) { described_class.new }

  let(:competition) { FactoryBot.create(:distance_competition) }
  let(:competitor) { FactoryBot.create(:event_competitor, competition: competition) }

  describe "#competitor_has_result?" do
    it "doesn't have results by default" do
      expect(calc).not_to be_competitor_has_result(competitor)
    end

    it "does have results with distance_attempts" do
      FactoryBot.create(:distance_attempt, competitor: competitor)
      expect(calc).to be_competitor_has_result(competitor.reload)
    end
  end

  describe "#competitor_result" do
    it "has nil for no result" do
      expect(calc.competitor_result(competitor)).to be_nil
    end

    describe "When the only results are DQ" do
      let!(:distance_attempt) { FactoryBot.create(:distance_attempt, competitor: competitor, fault: true) }

      it "returns nil" do
        expect(calc.competitor_result(competitor.reload)).to be_nil
      end
    end

    describe "when there are results" do
      let!(:distance_attempt) { FactoryBot.create(:distance_attempt, competitor: competitor, fault: false, distance: 14) }

      it "returns the distance" do
        expect(calc.competitor_result(competitor.reload)).to eq("14 cm")
      end
    end
  end

  describe "#competitor_comparable_result" do
    describe "with no results" do
      it { expect(calc.competitor_comparable_result(competitor)).to eq(0) }
    end

    describe "with a result" do
      let!(:distance_attempt) { FactoryBot.create(:distance_attempt, competitor: competitor, fault: false, distance: 14) }

      it { expect(calc.competitor_comparable_result(competitor)).to eq(14) }
    end
  end

  describe "with a tie_breaker result" do
    before do
      allow(competitor).to receive(:tie_break_adjustment).and_return(double(tie_break_place: 1))
    end

    it "has a non-0 tie breaker adjustment value" do
      expect(calc.competitor_tie_break_comparable_result(competitor)).to eq(0.9)
    end
  end

  it "has a 0 tie_breaker_adjustment" do
    expect(calc.competitor_tie_break_comparable_result(competitor)).to eq(0)
  end
end
