# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime
#  updated_at     :datetime
#  competitor_id  :integer
#
# Indexes
#
#  index_lane_assignments_on_competition_id                    (competition_id)
#  index_lane_assignments_on_competition_id_and_heat_and_lane  (competition_id,heat,lane) UNIQUE
#

require 'spec_helper'

describe LaneAssignmentsController do
  before(:each) do
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
    race_official = FactoryGirl.create(:user)
    race_official.add_role(:race_official, @competition)
    sign_in race_official
    @reg = FactoryGirl.create(:registrant)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
  end

  # This should return the minimal set of attributes required to create a valid
  # LaneAssignment. As you add validations to LaneAssignment, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { heat: 1,
      lane: 2,
      competitor_id: @competitor.id}
  end

  let(:lane_assignment) { FactoryGirl.create(:lane_assignment, competition: @competition) }

  describe "GET index" do
    it "shows all lane_assignments" do
      FactoryGirl.create(:lane_assignment, competition: @competition, heat: 3, lane: 4)
      get :index, params: { competition_id: @competition.id }

      assert_select "tr>td.heat", text: 3.to_s, count: 1
      assert_select "tr>td.lane", text: 4.to_s, count: 1

      assert_select "form", action: competition_lane_assignments_path(@competition), method: "post" do
        assert_select "select#lane_assignment_competitor_id", name: "lane_assignment[competitor_id]"
        assert_select "input#lane_assignment_heat", name: "lane_assignment[heat]"
        assert_select "input#lane_assignment_lane", name: "lane_assignment[lane]"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested lane_assignment form" do
      get :edit, params: { id: lane_assignment.to_param }

      assert_select "form", action: lane_assignment_path(lane_assignment), method: "post" do
        assert_select "select#lane_assignment_competitor_id", name: "lane_assignment[competitor_id]"
        assert_select "input#lane_assignment_heat", name: "lane_assignment[heat]"
        assert_select "input#lane_assignment_lane", name: "lane_assignment[lane]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new LaneAssignment" do
        expect do
          post :create, params: { lane_assignment: valid_attributes, competition_id: @competition.id }
        end.to change(LaneAssignment, :count).by(1)
      end

      it "redirects to the created lane_assignment" do
        post :create, params: { lane_assignment: valid_attributes, competition_id: @competition.id }
        expect(response).to redirect_to(competition_lane_assignments_path(@competition))
      end
    end

    describe "with invalid params" do
      it "does not create a new lane_assignment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        expect do
          post :create, params: { lane_assignment: { competition_id: "invalid value" }, competition_id: @competition.id }
        end.not_to change(LaneAssignment, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        post :create, params: { lane_assignment: { competition_id: "invalid value" }, competition_id: @competition.id }
        assert_select "h1", "#{@competition} New Lane Assignment"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested lane_assignment" do
        expect do
          put :update, params: { id: lane_assignment.to_param, lane_assignment: valid_attributes.merge(heat: 10) }
        end.to change { lane_assignment.reload.heat }
      end

      it "redirects to the lane_assignment" do
        put :update, params: { id: lane_assignment.to_param, lane_assignment: valid_attributes }
        expect(response).to redirect_to(competition_lane_assignments_path(@competition))
      end
    end

    describe "with invalid params" do
      it "does not update the lane_assignment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: lane_assignment.to_param, lane_assignment: { competition_id: "invalid value" } }
        end.not_to change { lane_assignment.reload.heat }
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        put :update, params: { id: lane_assignment.to_param, lane_assignment: { competition_id: "invalid value" } }
        assert_select "h1", "Editing lane_assignment"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested lane_assignment" do
      lane_assignment = FactoryGirl.create(:lane_assignment, competition: @competition)
      expect do
        delete :destroy, params: { id: lane_assignment.to_param }
      end.to change(LaneAssignment, :count).by(-1)
    end

    it "redirects to the lane_assignments list" do
      lane_assignment = FactoryGirl.create(:lane_assignment, competition: @competition)
      delete :destroy, params: { id: lane_assignment.to_param }
      expect(response).to redirect_to(competition_lane_assignments_path(@competition))
    end
  end
end
