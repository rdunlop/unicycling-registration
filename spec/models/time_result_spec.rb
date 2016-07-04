# == Schema Information
#
# Table name: time_results
#
#  id                  :integer          not null, primary key
#  competitor_id       :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string(255)      not null
#  comments            :text
#  comments_by         :string(255)
#  number_of_penalties :integer
#  entered_at          :datetime         not null
#  entered_by_id       :integer          not null
#  preliminary         :boolean
#  heat_lane_result_id :integer
#
# Indexes
#
#  index_time_results_on_competitor_id        (competitor_id)
#  index_time_results_on_heat_lane_result_id  (heat_lane_result_id) UNIQUE
#

require 'spec_helper'

describe TimeResult do
  before(:each) do
    @competitor = FactoryGirl.create(:event_competitor)
    @tr = FactoryGirl.create(:time_result, competitor: @competitor)
  end
  it "is valid from FactoryGirl" do
    expect(@tr.valid?).to eq(true)
  end

  it "requires a competitor" do
    @tr.competitor = nil
    expect(@tr.valid?).to eq(false)
  end

  it "cannot have a negative minutes value" do
    @tr.minutes = -1
    expect(@tr.valid?).to eq(false)
  end

  it "cannot have a negative seconds value" do
    @tr.seconds = -1
    expect(@tr.valid?).to eq(false)
  end

  it "cannot have a negative thousands value" do
    @tr.thousands = -1
    expect(@tr.valid?).to eq(false)
  end

  describe "With a new TimeResult" do
    subject { TimeResult.new }
    it "defaults to not DQ" do
      expect(subject.disqualified?).to eq(false)
    end

    it "defaults to 0 minutes" do
      expect(subject.minutes).to eq(0)
    end
    it "defaults to 0 seconds" do
      expect(subject.seconds).to eq(0)
    end
    it "defaults to 0 thousands" do
      expect(subject.thousands).to eq(0)
    end
  end

  it "refers to a competitor" do
    expect(@tr.competitor).to eq(@competitor)
  end

  describe "when it has a time" do
    before(:each) do
      @tr.minutes = 19
      @tr.seconds = 16
      @tr.thousands = 701
    end

    it "can print the full time when all values exist" do
      expect(@tr.full_time).to eq("19:16.701")
    end

    it "doesn't print the values if it is disqualified" do
      @tr.status = "DQ"
      expect(@tr.full_time).to eq("")
    end
  end

  it "can return the full time in thousands" do
    @tr.minutes = 1
    @tr.seconds = 2
    @tr.thousands = 3
    expect(@tr.full_time_in_thousands).to eq(62003)
  end
end
