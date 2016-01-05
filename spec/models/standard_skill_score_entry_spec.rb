# == Schema Information
#
# Table name: standard_skill_score_entries
#
#  id                              :integer          not null, primary key
#  standard_skill_score_id         :integer          not null
#  standard_skill_routine_entry_id :integer          not null
#  difficulty_devaluation_percent  :integer          not null
#  wave                            :integer          not null
#  line                            :integer          not null
#  cross                           :integer          not null
#  circle                          :integer          not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  standard_skill_entries_unique  (standard_skill_score_id,standard_skill_routine_entry_id) UNIQUE
#

require 'spec_helper'

describe StandardSkillScoreEntry do
  let(:judge) { FactoryGirl.create(:judge) }
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: judge.competition) }
  let(:sss) { FactoryGirl.create(:standard_skill_score) }
  let(:skill_points) { 5.1 }
  let(:standard_skill_entry) { FactoryGirl.create(:standard_skill_entry, points: skill_points)}
  let(:ssre) { FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: standard_skill_entry) }
  let(:devaluation_percent) { 50 }
  let(:ssse) { FactoryGirl.create(:standard_skill_score_entry, standard_skill_routine_entry: ssre, standard_skill_score: sss, difficulty_devaluation_percent: devaluation_percent) }

  it "should be able to have 2 different skills scored by the same judge" do
    score_entry = FactoryGirl.create(:standard_skill_score_entry)

    score_entry_2 = FactoryGirl.build(:standard_skill_score_entry,
                                      standard_skill_score: score_entry.standard_skill_score,
                                      standard_skill_routine_entry: FactoryGirl.create(:standard_skill_routine_entry))
    expect(score_entry_2).to be_valid
  end

  it "should store the score" do
    score_entry = StandardSkillScoreEntry.new
    expect(score_entry).not_to be_valid

    score_entry.standard_skill_score = sss
    expect(score_entry).not_to be_valid
    score_entry.standard_skill_routine_entry = ssre
    expect(score_entry).not_to be_valid

    score_entry.difficulty_devaluation_percent = 0

    score_entry.wave = 0
    expect(score_entry).not_to be_valid
    score_entry.line = 0
    expect(score_entry).not_to be_valid
    score_entry.cross = 0
    expect(score_entry).not_to be_valid
    score_entry.circle = 0
    expect(score_entry).to be_valid
  end

  describe "#difficulty_devaluation_score" do
    describe "with 0 devaluation" do
      let(:devaluation_percent) { 0 }
      it "returns the full point value when no devaluation" do
        expect(ssse.difficulty_devaluation_score).to eq(0)
      end
    end

    describe "with 50 devaluation" do
      let(:devaluation_percent) { 50 }
      it "returns 1/2 point value when no devaluation" do
        expect(ssse.difficulty_devaluation_score).to eq(skill_points / 2.0)
      end
    end

    describe "with 100 devaluation" do
      let(:devaluation_percent) { 100 }
      it "returns 0 point value when no devaluation" do
        expect(ssse.difficulty_devaluation_score).to eq(skill_points)
      end
    end
  end

  it { is_expected.to validate_inclusion_of(:difficulty_devaluation_percent).in_array([0, 50, 100]) }
  it { is_expected.to validate_presence_of(:standard_skill_score) }
  it { is_expected.to validate_presence_of(:standard_skill_routine_entry_id) }
  it { is_expected.to validate_presence_of(:wave) }
  it { is_expected.to validate_presence_of(:line) }
  it { is_expected.to validate_presence_of(:cross) }
  it { is_expected.to validate_presence_of(:circle) }
end
