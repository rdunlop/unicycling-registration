# == Schema Information
#
# Table name: standard_skill_score_entries
#
#  id                              :integer          not null, primary key
#  standard_skill_score_id         :integer          not null
#  standard_skill_routine_entry_id :integer          not null
#  devaluation                     :integer          not null
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
  let(:ssre) { FactoryGirl.create(:standard_skill_routine_entry) }

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

    score_entry.devaluation = 0

    score_entry.wave = 0
    expect(score_entry).not_to be_valid
    score_entry.line = 0
    expect(score_entry).not_to be_valid
    score_entry.cross = 0
    expect(score_entry).not_to be_valid
    score_entry.circle = 0
    expect(score_entry).to be_valid
  end

  it { is_expected.to validate_inclusion_of(:devaluation).in_array([0, 50, 100]) }
  it { is_expected.to validate_presence_of(:wave) }
  it { is_expected.to validate_presence_of(:line) }
  it { is_expected.to validate_presence_of(:cross) }
  it { is_expected.to validate_presence_of(:circle) }
end
