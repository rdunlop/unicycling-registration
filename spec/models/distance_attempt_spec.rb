# == Schema Information
#
# Table name: distance_attempts
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  distance      :decimal(4, )
#  fault         :boolean          default(FALSE), not null
#  judge_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_distance_attempts_competitor_id  (competitor_id)
#  index_distance_attempts_judge_id       (judge_id)
#

require 'spec_helper'

describe DistanceAttempt do
  before(:each) do
    @comp = FactoryGirl.create(:competitor)
    @judge = FactoryGirl.create(:judge)
  end
  describe "with a new distance attempt" do
    before(:each) do
      @da = DistanceAttempt.new
    end
    it "should have an associated competitor" do
      @da.distance = 1.0
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(false)

      @da.competitor_id = @comp.id
      expect(@da.valid?).to eq(true)
    end
    it "should have a distance" do
      @da.competitor_id = @comp.id
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(false)

      @da.distance = 1.0
      expect(@da.valid?).to eq(true)
    end
    it "should have a positive distance" do
      @da.competitor_id = @comp.id
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(false)

      @da.distance = -1.0
      expect(@da.valid?).to eq(false)
    end
    it "should have a distance less than 1000" do
      @da.competitor_id = @comp.id
      @da.judge_id = @judge.id
      @da.distance = 1000
      expect(@da.valid?).to eq(false)
    end
    it "should have a judge" do
      @da.competitor_id = @comp.id
      @da.distance = 100
      expect(@da.valid?).to eq(false)
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(true)
    end
  end
end
