require 'spec_helper'

RSpec.describe ScoreWeightCalculator::Weighted do
  let(:subject) { described_class.new([40, 40, 20]) }

  describe "with a score with 3 values" do
    let(:score) { [5, 5, 2] }

    it "weighs the 1st 2 columns more heavily" do
      expect(subject.total(score)).to eq(4.4)
    end
  end

  describe "when the weights are 33 perc. each" do
    let(:subject) { described_class.new([100.0 / 3, 100.0 / 3, 100.0 / 3]) }
    let(:score) { [5, 9, 5] }

    it "rounds to the nearest 4 digits" do
      expect(subject.total(score)).to eq(6.3333)
    end
  end

  describe "when the score ranges are inconsistent" do
    let(:score_ranges) { [10, 10, 10, 10, 5] }
    let(:subject) { described_class.new([25, 23, 20, 18, 14], score_ranges: score_ranges) }
    let(:max_score) { [10, 10, 10, 10, 5] }
    let(:min_score) { [0, 0, 0, 0, 0] }

    it "gives 100% for max score" do
      expect(subject.total(max_score)).to eq(100)
    end

    it "gives 0% for max score" do
      expect(subject.total(min_score)).to eq(0)
    end
  end
end
