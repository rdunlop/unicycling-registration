require 'spec_helper'

describe MultiLapResultCalculator do
  def calc(sub)
    described_class.new.competitor_comparable_result(sub)
  end

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
end
