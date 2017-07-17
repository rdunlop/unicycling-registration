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
      expect(judge.destroy).to eq(false)
    end
  end
end
