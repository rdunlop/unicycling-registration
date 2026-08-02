# == Schema Information
#
# Table name: judges
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  judge_type_id  :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  status         :string           default("active"), not null
#
# Indexes
#
#  index_judges_event_category_id                                (competition_id)
#  index_judges_judge_type_id                                    (judge_type_id)
#  index_judges_on_judge_type_id_and_competition_id_and_user_id  (judge_type_id,competition_id,user_id) UNIQUE
#  index_judges_user_id                                          (user_id)
#

require 'spec_helper'

describe Judge do
  describe "when the judge has scores" do
    let(:judge) { FactoryBot.create(:judge) }
    let(:competitor) { FactoryBot.create(:event_competitor, competition: judge.competition) }
    let!(:score) { FactoryBot.create(:score, competitor: competitor, judge: judge) }

    it "cannot destroy the judge" do
      judge.destroy
      expect(judge.destroyed?).to eq(false)
    end
  end

  context "With a high/long competition" do
    let(:competition) { FactoryBot.create(:distance_competition) }
    let(:judge) { FactoryBot.build(:judge, competition: competition) }
    let!(:judge_type) { FactoryBot.create(:judge_type, event_class: "High/Long", name: "High/Long Judge Type") }

    describe "when the judge type is valid for this competition" do
      it "can save the judge" do
        judge.judge_type = JudgeType.find_by(name: "High/Long Judge Type")
        expect(judge).to be_valid
      end
    end

    describe "when the judge type is not valid for this competition" do
      it "cannot save the judge" do
        judge.judge_type = JudgeType.find_by(name: "Flatland Judge Type")
        expect(judge).not_to be_valid
      end
    end
  end

  describe "#score_totals" do
    let(:competition) { FactoryBot.create(:competition) }
    let(:judge) { FactoryBot.create(:judge, competition: competition) }
    let(:judge_type) { judge.judge_type }
    let!(:competitor_a) { FactoryBot.create(:event_competitor, competition: competition, position: 1) }
    let!(:competitor_b) { FactoryBot.create(:event_competitor, competition: competition, position: 2) }
    let!(:competitor_c) { FactoryBot.create(:event_competitor, competition: competition, position: 3) }
    let!(:competitor_d) { FactoryBot.create(:event_competitor, competition: competition, position: 4) }

    context "when judge scores only some competitors" do
      before do
        FactoryBot.create(:score, judge: judge, competitor: competitor_a, val_1: 10, val_2: 5, val_3: 8)
        FactoryBot.create(:score, judge: judge, competitor: competitor_b, val_1: 8, val_2: 4, val_3: 6)
        FactoryBot.create(:score, judge: judge, competitor: competitor_c, val_1: 6, val_2: 3, val_3: 4)
        # competitor_d is not scored by this judge
      end

      it "includes 0 for unscored competitors" do
        totals = judge.score_totals
        expect(totals.length).to eq(4)
        expect(totals).to include(0)
      end

      it "includes scores for all competitors in order" do
        totals = judge.score_totals
        expect(totals.length).to eq(4)
        expect(totals[3]).to eq(0) # competitor_d should be 0
      end

      it "maintains the position order of competitors" do
        totals = judge.score_totals
        # First three should be non-zero (the scored competitors)
        expect(totals[0]).to be > 0
        expect(totals[1]).to be > 0
        expect(totals[2]).to be > 0
        # Fourth should be 0 (unscored competitor)
        expect(totals[3]).to eq(0)
      end
    end

    context "when judge scores all competitors" do
      before do
        FactoryBot.create(:score, judge: judge, competitor: competitor_a, val_1: 10, val_2: 5, val_3: 8)
        FactoryBot.create(:score, judge: judge, competitor: competitor_b, val_1: 8, val_2: 4, val_3: 6)
        FactoryBot.create(:score, judge: judge, competitor: competitor_c, val_1: 6, val_2: 3, val_3: 4)
        FactoryBot.create(:score, judge: judge, competitor: competitor_d, val_1: 4, val_2: 2, val_3: 2)
      end

      it "includes all scores without zeros" do
        totals = judge.score_totals
        expect(totals.length).to eq(4)
        expect(totals).not_to include(0)
      end
    end
  end

  describe "placing_points with incomplete judging (Artistic Freestyle IUF 2019)" do
    let(:event) { FactoryBot.create(:event) }
    let(:competition) do
      FactoryBot.create(:competition, event: event, scoring_class: "Artistic Freestyle IUF 2019")
    end
    let(:judge_type) do
      FactoryBot.create(:judge_type, name: "Performance", event_class: "Artistic Freestyle IUF 2019")
    end
    let(:judge1) { FactoryBot.create(:judge, competition: competition, judge_type: judge_type) }
    let(:judge2) { FactoryBot.create(:judge, competition: competition, judge_type: judge_type) }
    let!(:competitor_a) { FactoryBot.create(:event_competitor, competition: competition, position: 1) }
    let!(:competitor_b) { FactoryBot.create(:event_competitor, competition: competition, position: 2) }
    let!(:competitor_c) { FactoryBot.create(:event_competitor, competition: competition, position: 3) }
    let!(:competitor_d) { FactoryBot.create(:event_competitor, competition: competition, position: 4) }

    before do
      # Judge 1 scores A, B, C but not D
      FactoryBot.create(:score, judge: judge1, competitor: competitor_a, val_1: 5, val_2: 0, val_3: 0)
      FactoryBot.create(:score, judge: judge1, competitor: competitor_b, val_1: 3, val_2: 0, val_3: 0)
      FactoryBot.create(:score, judge: judge1, competitor: competitor_c, val_1: 2, val_2: 0, val_3: 0)

      # Judge 2 scores A and D but not B, C
      FactoryBot.create(:score, judge: judge2, competitor: competitor_a, val_1: 4, val_2: 0, val_3: 0)
      FactoryBot.create(:score, judge: judge2, competitor: competitor_d, val_1: 6, val_2: 0, val_3: 0)
    end

    it "places 0% for unscored competitors" do
      score_a_judge1 = judge1.scores.find_by(competitor: competitor_a)
      score_d_judge1 = judge1.scores.find_by(competitor: competitor_d)

      expect(score_a_judge1.placing_points).to be > 0
      expect(score_d_judge1).to be_nil # judge1 didn't score competitor_d
    end

    it "sums to 100% for each judge independently" do
      j1_totals = [
        judge1.scores.find_by(competitor: competitor_a).placing_points,
        judge1.scores.find_by(competitor: competitor_b).placing_points,
        judge1.scores.find_by(competitor: competitor_c).placing_points,
        0 # for unscored competitor_d
      ]

      j2_totals = [
        judge2.scores.find_by(competitor: competitor_a).placing_points,
        0, # for unscored competitor_b
        0, # for unscored competitor_c
        judge2.scores.find_by(competitor: competitor_d).placing_points
      ]

      expect(j1_totals.sum.round(1)).to eq(100.0)
      expect(j2_totals.sum.round(1)).to eq(100.0)
    end
  end
end
