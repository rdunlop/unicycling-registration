require 'spec_helper'

describe HeatLaneResultsController do
  before(:each) do
    @super_admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin_user
  end
  let(:competition) { FactoryGirl.create(:competition) }
  let(:heat_lane_judge_note) { FactoryGirl.create(:heat_lane_judge_note, competition: competition, heat: 2, lane: 1) }
  let!(:heat_lane_result) { FactoryGirl.create(:heat_lane_result, competition: competition, heat: 2, lane: 1)}

  # let!(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }
  # let!(:lane_assignment) { FactoryGirl.create(:lane_assignment, competition: competition, heat: 2, lane: 1, competitor: competitor) }
  describe "DELETE destroy" do
    it "renders" do
      expect do
        delete :destroy, params: { id: heat_lane_result.id }
      end.to change(HeatLaneResult, :count).by(-1)
    end
  end
end
