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
    let(:judge) { FactoryGirl.create(:judge) }
    let(:competitor) { FactoryGirl.create(:event_competitor, competition: judge.competition) }
    let!(:score) { FactoryGirl.create(:score, competitor: competitor, judge: judge) }

    it "cannot destroy the judge" do
      judge.destroy
      expect(judge.destroyed?).to eq(false)
    end
  end

  context "With a high/long competition" do
    let(:competition) { FactoryGirl.create(:distance_competition) }
    let(:judge) { FactoryGirl.build(:judge, competition: competition) }
    let!(:judge_type) { FactoryGirl.create(:judge_type, event_class: "High/Long", name: "High/Long Judge Type")}

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
end
