require 'spec_helper'

describe MultiLapResultCalculator do
  def calc(sub)
    described_class.new.competitor_comparable_result(sub)
  end

  let(:competition) { FactoryGirl.create(:timed_competition) }
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }

  let(:fast_competitor) { double(:competitor, best_time_in_thousands: 2.minutes, num_laps: 5, has_result?: true) }
  let(:faster_competitor) { double(:competitor, best_time_in_thousands: 1.minute, num_laps: 5, has_result?: true) }
  let(:slow_competitor) { double(:competitor, best_time_in_thousands: 3.minutes, num_laps: 4, has_result?: true) }
  let(:quit_competitor) { double(:competitor, best_time_in_thousands: 1.minute, num_laps: 1, has_result?: true) }

  it "creates comparable_results of suitable comparison" do
    expect(calc(fast_competitor) > calc(faster_competitor)).to be_truthy
    expect(calc(slow_competitor) > calc(faster_competitor)).to be_truthy
    expect(calc(quit_competitor) > calc(faster_competitor)).to be_truthy

    expect(calc(slow_competitor) > calc(fast_competitor)).to be_truthy
    expect(calc(quit_competitor) > calc(fast_competitor)).to be_truthy

    expect(calc(quit_competitor) > calc(slow_competitor)).to be_truthy
  end

  describe "#competitor_has_result?" do
    it "doesn't have results by default" do
      expect(described_class.new.competitor_has_result?(competitor)).to be_falsey
    end

    it "does have results with finish_times" do
      FactoryGirl.create(:time_result, competitor: competitor)
      expect(described_class.new.competitor_has_result?(competitor.reload)).to be_truthy
    end
  end

  describe "#competitor_result" do
    it "has nil for no result" do
      expect(described_class.new.competitor_result(competitor)).to be_nil
    end

    describe "When the only results are DQ" do
      let!(:time_result) { FactoryGirl.create(:time_result, competitor: competitor, status: "DQ") }

      it "returns nil" do
        expect(described_class.new.competitor_result(competitor.reload)).to be_nil
      end
    end

    describe "when there are results" do
      let!(:time_result) { FactoryGirl.create(:time_result, competitor: competitor, minutes: 1, number_of_laps: 1) }

      it "returns the time" do
        expect(described_class.new.competitor_result(competitor.reload)).to eq("1:00 (1 laps)")
      end
    end
  end
end
