require 'spec_helper'

RSpec.describe ArtisticResultCalculator2017 do
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

  describe "#total_points_for_judge_type with incomplete judging" do
    let(:competition) { FactoryBot.create(:competition, scoring_class: "Artistic Freestyle IUF 2019") }
    let(:judge_type) { FactoryBot.create(:judge_type, name: "Performance", event_class: "Artistic Freestyle IUF 2019") }
    let(:judge_with_scores) { FactoryBot.create(:judge, competition: competition, judge_type: judge_type) }
    let(:judge_without_scores) { FactoryBot.create(:judge, competition: competition, judge_type: judge_type) }
    let(:competitor) { FactoryBot.create(:event_competitor, competition: competition) }
    let(:calc) { described_class.new }

    context "when some judges have no scores at all" do
      before do
        # Judge with scores scores this competitor
        FactoryBot.create(:score, judge: judge_with_scores, competitor: competitor, val_1: 10, val_2: 0, val_3: 0)
        # judge_without_scores has NO scores for any competitor
      end

      it "excludes judges with no scores from the average" do
        avg = calc.total_points_for_judge_type(competitor, judge_type)

        # Should be 100% (or close), not 50% (which would be if judge_without_scores was included with 0%)
        expect(avg).to be > 90
      end
    end

    context "when judges score different competitors" do
      let(:competitor_b) { FactoryBot.create(:event_competitor, competition: competition, position: 2) }
      let(:judge2) { FactoryBot.create(:judge, competition: competition, judge_type: judge_type) }

      before do
        # Judge 1 scores competitor A only
        FactoryBot.create(:score, judge: judge_with_scores, competitor: competitor, val_1: 5, val_2: 0, val_3: 0)
        # Judge 2 scores competitor B only
        FactoryBot.create(:score, judge: judge2, competitor: competitor_b, val_1: 5, val_2: 0, val_3: 0)
      end

      it "includes 0% for judges who didn't score this competitor, but excludes judges with no scores" do
        avg_a = calc.total_points_for_judge_type(competitor, judge_type)

        # Judge 1 scored A: 100%
        # Judge 2 didn't score A but has scores: 0%
        # judge_without_scores has no scores at all: excluded
        # Average should be (100 + 0) / 2 = 50%
        expect(avg_a).to be_within(5).of(50)
      end
    end
  end
end
