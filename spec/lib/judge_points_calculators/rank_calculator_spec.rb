require 'spec_helper'

describe RankCalculator do
  subject { RankCalculator.new(all_scores, all_tie_scores) }

  describe "when determining place from points" do
    let(:first) { 1 }
    let(:second) { 2 }
    let(:all_scores) { [first, second, 3, 4] }
    let(:tie_score) { 1 }
    let(:all_tie_scores) { [1, 2, 3, 4] }

    it { expect(subject.rank(first, tie_score)).to eq(1) }
    it { expect(subject.rank(second, 2)).to eq(2) }

    # if the overall scores are tied, fall back to the secondary scores for tie-breaker
    describe "overall scores are tied" do
      let(:all_scores) { [1.5, 1.5] }
      let(:all_tie_scores) { [1,2] }

      it { expect(subject.rank(1.5, 1)).to eq(1) }
      it { expect(subject.rank(1.5, 2)).to eq(2) }
    end
  end
end
