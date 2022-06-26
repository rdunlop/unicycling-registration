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
end
