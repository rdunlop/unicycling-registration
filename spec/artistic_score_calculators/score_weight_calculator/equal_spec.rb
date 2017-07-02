require 'spec_helper'

RSpec.describe ScoreWeightCalculator::Equal do
  describe "with a score with 4 values" do
    let(:score) { [1, 3, 5, 7] }

    it "sums them up" do
      expect(subject.total(score)).to eq(16)
    end
  end
end
