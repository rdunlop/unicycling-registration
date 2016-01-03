require 'spec_helper'

describe DistanceResultCalculator do
  let(:calc) { described_class.new }

  let(:competition) { FactoryGirl.create(:distance_competition) }
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }

  describe "#scoring_description" do
    it { expect(calc.scoring_description).not_to eq("") }
  end

  describe "#competitor_has_result?" do
    it "doesn't have results by default" do
      expect(calc.competitor_has_result?(competitor)).to be_falsey
    end

    it "does have results with distance_attempts" do
      FactoryGirl.create(:distance_attempt, competitor: competitor)
      expect(calc.competitor_has_result?(competitor.reload)).to be_truthy
    end
  end

  describe "#competitor_result" do
    it "has nil for no result" do
      expect(calc.competitor_result(competitor)).to be_nil
    end

    describe "When the only results are DQ" do
      let!(:distance_attempt) { FactoryGirl.create(:distance_attempt, competitor: competitor, fault: true) }

      it "returns nil" do
        expect(calc.competitor_result(competitor.reload)).to be_nil
      end
    end

    describe "when there are results" do
      let!(:distance_attempt) { FactoryGirl.create(:distance_attempt, competitor: competitor, fault: false, distance: 14) }

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
      let!(:distance_attempt) { FactoryGirl.create(:distance_attempt, competitor: competitor, fault: false, distance: 14) }

      it { expect(calc.competitor_comparable_result(competitor)).to eq(14) }
    end
  end

  describe "with a tie_breaker result" do
    before :each do
      allow(competitor).to receive(:tie_break_adjustment).and_return(double(tie_break_place: 1))
    end

    it "should have a non-0 tie breaker adjustment value" do
      expect(calc.competitor_tie_break_comparable_result(competitor)).to eq(0.9)
    end
  end

  it "should have a 0 tie_breaker_adjustment" do
    expect(calc.competitor_tie_break_comparable_result(competitor)).to eq(0)
  end
end
