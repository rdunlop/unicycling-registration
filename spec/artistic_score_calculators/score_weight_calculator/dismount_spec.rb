require 'spec_helper'

RSpec.describe ScoreWeightCalculator::Dismount do
  let(:subject) { described_class.new(10) }

  describe "with a score with 1 major, 1 minor" do
    let(:score) { [1, 1] }

    it "can calculate the mistakes and dismount scores" do
      expect(subject.mistake_score(score)).to eq(1.5)
      expect(subject.total(score)).to be_within(0.1).of(9.525)
    end
  end
end
