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
#  val_5         :decimal(5, 3)
#
# Indexes
#
#  index_scores_competitor_id                  (competitor_id)
#  index_scores_judge_id                       (judge_id)
#  index_scores_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

require 'spec_helper'

describe Score do
  let(:judge) { FactoryBot.build_stubbed(:judge) }
  let(:subject) { FactoryBot.build_stubbed(:score, val_1: 10, val_2: 1.2, judge: judge) }

  describe "when the score is invalid" do
    before do
      allow(subject).to receive(:invalid?).and_return(true)
    end

    it "says that it has a judge_place of 0" do
      expect(subject.judged_place).to be_nil
    end

    it "says that it has a judge_points of 0" do
      expect(subject.placing_points).to be_nil
    end
  end

  describe "#raw_scores" do
    context "when judge_type specifies 2 valid scores" do
      let(:judge_type) { FactoryBot.build_stubbed(:judge_type, val_1_max: 10, val_2_max: 10, val_3_max: 0, val_4_max: 0) }
      let(:judge) { FactoryBot.build_stubbed(:judge, judge_type: judge_type) }

      it "returns only 2 scores" do
        expect(subject.raw_scores).to eq([10.0, 1.2])
      end
    end
  end

  describe "when calculating totals" do
    it "Must have a value above 0" do
      subject.val_1 = -1
      subject.val_2 = -1
      expect(subject.valid?).to eq(false)
    end

    it "totals the values to create the Total" do
      subject.val_1 = 1.0
      subject.val_2 = 2.0
      subject.val_3 = 3.0
      subject.val_4 = 4.0

      expect(subject.total).to eq(10)
    end
  end
end

describe Score do
  before do
    @judge = FactoryBot.create(:judge)
  end

  it "is not able to have the same score/judge created twice" do
    score = FactoryBot.create(:score)

    score2 = FactoryBot.build(:score, judge: score.judge, competitor: score.competitor)

    expect(score2.valid?).to eq(false)
  end

  it "stores the judge" do
    score = described_class.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
    expect(score.valid?).to eq(false)
    expect(score.total).to be_nil
    score.competitor = FactoryBot.build_stubbed(:event_competitor)
    expect(score.valid?).to eq(false)
    score.judge = @judge
    expect(score.valid?).to eq(true)
    expect(score.total).to eq(10)
  end
  it "validates the bounds of the Values" do
    score = described_class.new
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
    before do
      @jt = FactoryBot.create(:judge_type, val_1_max: 5, val_2_max: 6, val_3_max: 7, val_4_max: 20)
      @judge = FactoryBot.create(:judge, judge_type: @jt)
      @score = described_class.new
      @score.val_1 = 1.0
      @score.val_2 = 2.0
      @score.val_3 = 3.0
      @score.val_4 = 4.0
      @score.competitor_id = 4
      @score.judge = @judge
    end

    it "validates the bounds of the values when the judge_type specifies different max" do
      score = @score

      expect(score.valid?).to eq(true)
      score.val_1 = 10.0
      expect(score.valid?).to eq(false)
      score.val_1 = 5.0
      expect(score.valid?).to eq(true)
    end
    it "checks each column separately for max" do
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
