require 'spec_helper'

describe HeatLaneJudgeNotesController do
  before(:each) do
    @super_admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin_user
  end
  let(:competition) { FactoryGirl.create(:competition) }
  let(:heat_lane_judge_note) { FactoryGirl.create(:heat_lane_judge_note, competition: competition, heat: 2, lane: 1) }
  let!(:heat_lane_result) { FactoryGirl.create(:heat_lane_result, competition: competition, heat: 2, lane: 1)}
  let!(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }
  let!(:lane_assignment) { FactoryGirl.create(:lane_assignment, competition: competition, heat: 2, lane: 1, competitor: competitor) }

  describe "PUT merge" do
    it "redirects" do
      put :merge, params: { competition_id: competition.id, id: heat_lane_judge_note.id }
      expect(response).to redirect_to(competition_heat_review_path(competition, 2))
    end
  end
end
