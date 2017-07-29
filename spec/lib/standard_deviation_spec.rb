require 'spec_helper'

describe StandardDeviation do
  let(:subject) { described_class.new(array) }
  let(:sd) { subject.standard_deviation }

  context "with a single datapoint" do
    let(:array) { [1] }

    it "returns a standard deviation of NaN" do
      expect(sd.nan?).to be_truthy
    end
  end

  context "with a 3-point dataset" do
    let(:array) { [1, 2, 3] }

    it "returns a standard deviation of 1" do
      expect(sd).to eq(1)
    end
  end

  describe "#num_standards_from_the_mean" do
    context "with a 3 element dataset" do
      let(:array) { [1, 5, 7] }

      it "has a mean of 4.33" do
        expect(subject.mean).to be_within(0.01).of(4.33)
      end

      it "has a standard deviation of 3.05" do
        expect(sd).to be_within(0.1).of(3.05)
      end

      it "shows that 1 is ~1 standard deviations from the mean" do
        expect(subject.num_standards_from_the_mean(1)).to be_within(0.01).of(1.09)
      end

      it "shows that 10 is ~2 standard deviations from the mean" do
        expect(subject.num_standards_from_the_mean(10)).to be_within(0.01).of(1.85)
      end
    end
  end
end
