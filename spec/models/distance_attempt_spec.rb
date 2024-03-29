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
  before do
    @comp = FactoryBot.create(:event_competitor, :with_high_jump_competition)
    @judge = FactoryBot.create(:judge)
  end

  describe "with a new distance attempt" do
    before do
      @da = described_class.new
    end

    it "has an associated competitor" do
      @da.distance = 1.0
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(false)

      @da.competitor_id = @comp.id
      expect(@da.valid?).to eq(true)
    end

    it "has a distance" do
      @da.competitor_id = @comp.id
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(false)

      @da.distance = 1.0
      expect(@da.valid?).to eq(true)
    end

    it "has a positive distance" do
      @da.competitor_id = @comp.id
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(false)

      @da.distance = -1.0
      expect(@da.valid?).to eq(false)
    end

    it "has a distance less than 1000" do
      @da.competitor_id = @comp.id
      @da.judge_id = @judge.id
      @da.distance = 1000
      expect(@da.valid?).to eq(false)
    end

    it "has a judge" do
      @da.competitor_id = @comp.id
      @da.distance = 100
      expect(@da.valid?).to eq(false)
      @da.judge_id = @judge.id
      expect(@da.valid?).to eq(true)
    end
  end
end
