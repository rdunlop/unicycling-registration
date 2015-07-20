require 'spec_helper'

describe TimeResultCalculator do
  let(:start_times) { [] }
  let(:finish_times) { [2000] }
  let(:competition_start_time) { 0 }
  let(:lower_is_better) { true }
  let(:calculator) { described_class.new(start_times, finish_times, competition_start_time, lower_is_better) }

  describe "with only a finish time" do
    it "returns the finish time" do
      expect(calculator.best_time_in_thousands).to eq(2000)
    end
  end

  describe "with a start and finish time" do
    let(:start_times) { [100] }

    it "returns the finish time adjusted by the start time" do
      expect(calculator.best_time_in_thousands).to eq(1900)
    end
  end

  describe "with only a finish time, but with a competition_start_time" do
    let(:competition_start_time) { 1 } # XXX make the argument in thousands,not-seconds?

    it "returns the finish time adjusted by the competition_start_time" do
      expect(calculator.best_time_in_thousands).to eq(1000)
    end
  end

  describe "with multiple finish and start times" do
    let(:start_times) { [2000, 1000, 3000] }
    let(:finish_times) { [2900, 1800, 4000] }
    it "determines the actual best time" do
      expect(calculator.best_time_in_thousands).to eq(800)
    end
  end
end
