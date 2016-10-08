require 'spec_helper'

describe StandardSkillResultCalculator do
  let(:competition) { FactoryGirl.create(:competition, :standard_skill) }
  let(:judge_type) { FactoryGirl.create(:judge_type, event_class: "Standard Skill") }
  let(:scores) do
    [
      double(:standard_skill_score, total_execution_devaluation: 10, total_difficulty_devaluation: 4),
      double(:standard_skill_score, total_execution_devaluation: 14, total_difficulty_devaluation: 6)
    ]
  end
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }

  # routine score 90
  # judge 1 devaluation of 14
  # judge 2 devaluation of 20
  # total judge 1 = 76
  # total judge 2 = 70
  # average total = 73
  # judge 1 execution_devaluation 10
  # judge 2 execution_devaluation 14
  # total execution devaluation = 24

  before do
    allow(competitor).to receive(:standard_skill_scores).and_return(scores)

    routine = double(:standard_skill_routine, total_skill_points: 90)
    allow(competitor).to receive(:standard_skill_routine).and_return(routine)
  end

  describe "#competitor_comparable_result" do
    it "averages the scores" do
      expect(described_class.new.competitor_comparable_result(competitor)).to eq(73)
    end

    describe "with a very low score" do
      let(:scores) do
        [
          double(:standard_skill_score, total_execution_devaluation: 100, total_difficulty_devaluation: 4),
          double(:standard_skill_score, total_execution_devaluation: 140, total_difficulty_devaluation: 6)
        ]
      end

      it "doesn't go below 0" do
        expect(described_class.new.competitor_comparable_result(competitor)).to eq(0)
      end
    end
  end

  describe "#competitor_tie_break_comparable_result" do
    it "lists the total execution devaluation" do
      expected = ((90 - 10) + (90 - 14)) / 2
      expect(described_class.new.competitor_tie_break_comparable_result(competitor)).to eq(expected)
    end
  end
end
