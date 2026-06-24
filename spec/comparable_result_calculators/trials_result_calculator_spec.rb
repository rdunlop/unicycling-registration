require 'spec_helper'

describe TrialsResultCalculator do
  let(:calc) { described_class.new }

  let(:competition) { FactoryBot.create(:trials_competition) }
  let(:competitor) { FactoryBot.create(:event_competitor, competition: competition) }

  describe "#competitor_has_result?" do
    it "doesn't have results by default" do
      expect(calc).not_to be_competitor_has_result(competitor)
    end

    it "does have results with trials_result" do
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

    describe "with multiple competitors" do
      let(:competitor2) { FactoryBot.create(:event_competitor, competition: competition) }
      let(:competitor3) { FactoryBot.create(:event_competitor, competition: competition) }
      let(:competitor4) { FactoryBot.create(:event_competitor, competition: competition) }
      let(:competitor5) { FactoryBot.create(:event_competitor, competition: competition) }

      let!(:high_point_fast_trials_result) { FactoryBot.create(:trials_result, competitor: competitor, points: 50, minutes: 30, seconds: 28) }
      let!(:high_points_low_trials_result) { FactoryBot.create(:trials_result, competitor: competitor2, points: 50, minutes: 180, seconds: 42) }
      let!(:low_points_fast_trials_result) { FactoryBot.create(:trials_result, competitor: competitor3, points: 25, minutes: 22, seconds: 57) }
      let!(:low_points_slow_trials_result) { FactoryBot.create(:trials_result, competitor: competitor4, points: 25, minutes: 175, seconds: 18) }
      let!(:low_points_slow_trials_result2) { FactoryBot.create(:trials_result, competitor: competitor5, points: 25, minutes: 175, seconds: 18) }

      it "creates comparable_results of suitable comparison" do
        expect(calc.competitor_comparable_result(competitor) > calc.competitor_comparable_result(competitor2)).to be_truthy
        expect(calc.competitor_comparable_result(competitor) > calc.competitor_comparable_result(competitor3)).to be_truthy
        expect(calc.competitor_comparable_result(competitor) > calc.competitor_comparable_result(competitor4)).to be_truthy
        expect(calc.competitor_comparable_result(competitor) > calc.competitor_comparable_result(competitor5)).to be_truthy

        expect(calc.competitor_comparable_result(competitor2) > calc.competitor_comparable_result(competitor3)).to be_truthy
        expect(calc.competitor_comparable_result(competitor2) > calc.competitor_comparable_result(competitor4)).to be_truthy
        expect(calc.competitor_comparable_result(competitor2) > calc.competitor_comparable_result(competitor5)).to be_truthy

        expect(calc.competitor_comparable_result(competitor3) > calc.competitor_comparable_result(competitor4)).to be_truthy
        expect(calc.competitor_comparable_result(competitor3) > calc.competitor_comparable_result(competitor5)).to be_truthy

        expect(calc.competitor_comparable_result(competitor4) == calc.competitor_comparable_result(competitor5)).to be_truthy
      end
    end
  end
end
