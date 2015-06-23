# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_scores_competitor_id                  (competitor_id)
#  index_scores_judge_id                       (judge_id)
#  index_scores_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

require 'spec_helper'

describe Score do
  let(:judge) { FactoryGirl.build_stubbed(:judge) }
  let(:subject) { FactoryGirl.build_stubbed(:score, val_1: 10, judge: judge) }

  describe "when the score is invalid" do
    before(:each) do
      allow(subject).to receive(:invalid?).and_return(true)
    end

    it "says that it has a judge_place of 0" do
      expect(subject.judged_place).to be_nil
    end

    it "says that it has a judge_points of 0" do
      expect(subject.placing_points).to be_nil
    end
  end

  describe "when calculating totals" do
    it "Must have a value above 0" do
      subject.val_1 = -1
      subject.val_2 = -1
      expect(subject.valid?).to eq(false)
    end

    it "should total the values to create the Total" do
      subject.val_1 = 1.0
      subject.val_2 = 2.0
      subject.val_3 = 3.0
      subject.val_4 = 4.0

      expect(subject.total).to eq(10)
    end
  end
end

describe Score do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
  end

  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:score)

    score2 = FactoryGirl.build(:score, judge: score.judge, competitor: score.competitor)

    expect(score2.valid?).to eq(false)
  end

  it "should store the judge" do
    score = Score.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
    expect(score.valid?).to eq(false)
    expect(score.total).to eq(0)
    score.competitor_id = 4
    expect(score.valid?).to eq(false)
    score.judge = @judge
    expect(score.valid?).to eq(true)
  end
  it "should validate the bounds of the Values" do
    score = Score.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
    score.competitor_id = 4
    score.judge = @judge
    expect(score.valid?).to eq(true)
    score.val_1 = 11.0
    expect(score.valid?).to eq(false)
  end
  describe "when the score is based on a judge with judge_type" do
    before(:each) do
      @jt = FactoryGirl.create(:judge_type, val_1_max: 5, val_2_max: 6, val_3_max: 7, val_4_max: 20)
      @judge = FactoryGirl.create(:judge, judge_type: @jt)
      @score = Score.new
      @score.val_1 = 1.0
      @score.val_2 = 2.0
      @score.val_3 = 3.0
      @score.val_4 = 4.0
      @score.competitor_id = 4
      @score.judge = @judge
    end
    it "Should validate the bounds of the values when the judge_type specifies different max" do
      score = @score

      expect(score.valid?).to eq(true)
      score.val_1 = 10.0
      expect(score.valid?).to eq(false)
      score.val_1 = 5.0
      expect(score.valid?).to eq(true)
    end
    it "should check each column separately for max" do
      score = @score
      expect(score.valid?).to eq(true)

      score.val_1 = 6.0
      expect(score.valid?).to eq(false)
      score.val_1 = 5.0
      expect(score.valid?).to eq(true)

      score.val_2 = 7.0
      expect(score.valid?).to eq(false)
      score.val_2 = 2.0
      expect(score.valid?).to eq(true)

      score.val_3 = 9.0
      expect(score.valid?).to eq(false)
      score.val_3 = 7.0
      expect(score.valid?).to eq(true)

      score.val_4 = 21.0
      expect(score.valid?).to eq(false)
      score.val_4 = 20.0
      expect(score.valid?).to eq(true)
    end
  end
end
