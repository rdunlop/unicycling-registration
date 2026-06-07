require 'spec_helper'

describe TrialsResultCalculator do
  let(:calc) { described_class.new }

  let(:competition) { FactoryBot.create(:trials_competition) }
  let(:competitor) { FactoryBot.create(:event_competitor, competition: competition) }

  describe "#competitor_has_result?" do
    it "doesn't have results by default" do
      expect(calc).not_to be_competitor_has_result(competitor)
    end

    it "does have results with distance_attempts" do
      FactoryBot.create(:trials_result, competitor: competitor)
      expect(calc).to be_competitor_has_result(competitor.reload)
    end
  end

  describe "#competitor_result" do
    it "has nil for no result" do
      expect(calc.competitor_result(competitor)).to be_nil
    end

    describe "When the only results are DQ" do
      let!(:trials_result) { FactoryBot.create(:trials_result, competitor: competitor, status: "DQ") }

      it "returns nil" do
        expect(calc.competitor_result(competitor.reload)).to be_nil
      end
    end

    describe "when there are results" do
      let!(:trials_result) { FactoryBot.create(:trials_result, competitor: competitor, points: 50, minutes: 55, seconds: 42, details: "50 pts (55m 42s)") }

      it "returns the formatted result" do
        expect(calc.competitor_result(competitor.reload)).to eq("50 pts (55m 42s)")
      end
    end
  end

  describe "#competitor_comparable_result" do
    describe "with no results" do
      it { expect(calc.competitor_comparable_result(competitor)).to eq(0) }
    end

    describe "with a result" do
      let!(:trials_result) { FactoryBot.create(:trials_result, competitor: competitor, points: 50, minutes: 55, seconds: 42) }

      it { expect(calc.competitor_comparable_result(competitor)).to eq(49996658) }
    end
  end
end
