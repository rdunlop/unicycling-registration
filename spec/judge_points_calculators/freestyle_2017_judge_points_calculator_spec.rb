require 'spec_helper'

describe Freestyle_2017_JudgePointsCalculator do
  let(:subject) { described_class.new }

  describe "#calculate_score_total" do
    let(:num_members) { 1 }
    let(:score) do
      double(
        judge_type: double(name: judge_type),
        competitor: double(active_members: double(size: num_members)),
        raw_scores: raw_scores
      )
    end

    context "for a Technical Judge" do
      let(:raw_scores) { [10, 8, 4] }
      let(:judge_type) { "Technical" }

      it "gives a weighted average to the scores" do
        expect(subject.calculate_score_total(score)).to eq(7)
      end
    end

    context "for a Performance Judge" do
      let(:raw_scores) { [10, 8, 4] }
      let(:judge_type) { "Performance" }

      it "gives a equal weight to the scores" do
        expect(subject.calculate_score_total(score)).to eq(22)
      end
    end

    context "for a Dismount Judge" do
      let(:raw_scores) { [10, 8, 4] }
      let(:judge_type) { "Dismount" }
      let(:num_members) { 10 }

      it "gives a value based on the number of competitors to the scores" do
        expect(subject.calculate_score_total(score)).to be_within(0.1).of(5.57)
      end
    end
  end
end
