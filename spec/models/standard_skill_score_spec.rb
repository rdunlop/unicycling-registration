# == Schema Information
#
# Table name: standard_skill_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer          not null
#  judge_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_standard_skill_scores_on_competitor_id               (competitor_id)
#  index_standard_skill_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id) UNIQUE
#

require 'spec_helper'

describe StandardSkillScore do
  let(:score) { FactoryGirl.create(:standard_skill_score) }
  let(:difficulty_percent) { 50 }
  let(:standard_skill_entry) { FactoryGirl.create(:standard_skill_entry, points: 5.2) }
  let(:standard_skill_routine_entry) { FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: standard_skill_entry) }
  let!(:standard_skill_score_entry) do
    FactoryGirl.create(:standard_skill_score_entry,
                       standard_skill_score: score,
                       standard_skill_routine_entry: standard_skill_routine_entry,
                       difficulty_devaluation_percent: difficulty_percent)
  end

  it "should not be able to have the same score/judge created twice" do
    score2 = FactoryGirl.build(:standard_skill_score, judge: score.judge,
                                                      competitor: score.competitor)

    expect(score2).to be_invalid
  end

  describe "#total_difficulty_devaluation" do
    describe "with 0 devaluations" do
      let(:difficulty_percent) { 0 }
      it "returns 0 total devaluation" do
        expect(score.total_difficulty_devaluation).to eq(0)
      end
    end

    describe "with 50% devaluation" do
      let(:difficulty_percent) { 50 }
      it "returns the total devaluation" do
        expect(score.total_difficulty_devaluation).to eq(2.6)
      end
    end

    describe "with 100% devaluation" do
      let(:difficulty_percent) { 100 }
      it "returns the total devaluation" do
        expect(score.total_difficulty_devaluation).to eq(5.2)
      end
    end
  end

  describe "with multiple score_entries" do
    let!(:standard_skill_score_entry_2) do
      FactoryGirl.create(:standard_skill_score_entry,
                         standard_skill_score: score,
                         wave: 1,
                         line: 2,
                         cross: 3,
                         circle: 4
                        )
    end
    let!(:standard_skill_score_entry_3) do
      FactoryGirl.create(:standard_skill_score_entry,
                         standard_skill_score: score,
                         wave: 1,
                         line: 2,
                         cross: 3,
                         circle: 4
                        )
    end

    describe "#wave_count" do
      it "totals the wave from all entries" do
        expect(score.wave_count).to eq(2)
      end
    end

    describe "#line_count" do
      it "totals the line from all entries" do
        expect(score.line_count).to eq(4)
      end
    end

    describe "#cross_count" do
      it "totals the cross from all entries" do
        expect(score.cross_count).to eq(6)
      end
    end

    describe "#circle_count" do
      it "totals the circle from all entries" do
        expect(score.circle_count).to eq(8)
      end
    end

    describe "#total_execution_devaluation" do
      it "totals all devaluations" do
        # ~ = 2 * .5 = 1
        # / = 4 * 1  = 4
        # + = 6 * 2  = 12
        # O = 8 * 3  = 24
        # total:    = 41
        expect(score.total_execution_devaluation).to eq(41)
      end
    end
  end

  it { is_expected.to validate_presence_of(:competitor_id) }
  it { is_expected.to validate_presence_of(:judge_id) }
end
