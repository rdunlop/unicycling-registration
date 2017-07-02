require 'spec_helper'

RSpec.describe ScoreWeightCalculator::Weighted do
  let(:subject) { described_class.new([40, 40, 20]) }

  describe "with a score with 3 values" do
    let(:score) { [5, 5, 2] }

    it "weighs the 1st 2 columns more heavily" do
      expect(subject.total(score)).to eq(4.4)
    end
  end
end
