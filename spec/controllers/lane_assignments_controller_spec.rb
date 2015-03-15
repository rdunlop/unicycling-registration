require 'spec_helper'

describe LaneAssignmentsController do
  before(:each) do
    sign_in FactoryGirl.create(:admin_user)
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
    @reg = FactoryGirl.create(:registrant)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
  end

  # This should return the minimal set of attributes required to create a valid
  # LaneAssignment. As you add validations to LaneAssignment, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "heat" => 1,
      "lane" => 2,
      "competitor_id" => @competitor.id}
  end

  let(:lane_assignment) { FactoryGirl.create(:lane_assignment, :competition => @competition) }

  describe "GET index" do
    it "assigns all lane_assignments as @lane_assignments" do
      la = FactoryGirl.create(:lane_assignment, :competition => @competition)
      get :index, {:competition_id => @competition.id}
      expect(assigns(:lane_assignments)).to eq([la])
    end
  end

  describe "GET edit" do
    it "assigns the requested lane_assignment as @lane_assignment" do
      get :edit, {:id => lane_assignment.to_param}
      expect(assigns(:lane_assignment)).to eq(lane_assignment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new LaneAssignment" do
        expect {
          post :create, {:lane_assignment => valid_attributes, :competition_id => @competition.id}
        }.to change(LaneAssignment, :count).by(1)
      end

      it "assigns a newly created lane_assignment as @lane_assignment" do
        post :create, {:lane_assignment => valid_attributes, :competition_id => @competition.id}
        expect(assigns(:lane_assignment)).to be_a(LaneAssignment)
        expect(assigns(:lane_assignment)).to be_persisted
      end

      it "redirects to the created lane_assignment" do
        post :create, {:lane_assignment => valid_attributes, :competition_id => @competition.id}
        expect(response).to redirect_to(competition_lane_assignments_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved lane_assignment as @lane_assignment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        post :create, {:lane_assignment => { "competition_id" => "invalid value" }, :competition_id => @competition.id}
        expect(assigns(:lane_assignment)).to be_a_new(LaneAssignment)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        post :create, {:lane_assignment => { "competition_id" => "invalid value" }, :competition_id => @competition.id}
        expect(response).to render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested lane_assignment" do
        # Assuming there are no other lane_assignments in the database, this
        # specifies that the LaneAssignment created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(LaneAssignment).to receive(:update_attributes).with({})
        put :update, {:id => lane_assignment.to_param, :lane_assignment => { "something" => "1" }}
      end

      it "assigns the requested lane_assignment as @lane_assignment" do
        put :update, {:id => lane_assignment.to_param, :lane_assignment => valid_attributes}
        expect(assigns(:lane_assignment)).to eq(lane_assignment)
      end

      it "redirects to the lane_assignment" do
        put :update, {:id => lane_assignment.to_param, :lane_assignment => valid_attributes}
        expect(response).to redirect_to(competition_lane_assignments_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns the lane_assignment as @lane_assignment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        put :update, {:id => lane_assignment.to_param, :lane_assignment => { "competition_id" => "invalid value" }}
        expect(assigns(:lane_assignment)).to eq(lane_assignment)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(LaneAssignment).to receive(:save).and_return(false)
        put :update, {:id => lane_assignment.to_param, :lane_assignment => { "competition_id" => "invalid value" }}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested lane_assignment" do
      lane_assignment = FactoryGirl.create(:lane_assignment)
      expect {
        delete :destroy, {:id => lane_assignment.to_param}
      }.to change(LaneAssignment, :count).by(-1)
    end

    it "redirects to the lane_assignments list" do
      lane_assignment = FactoryGirl.create(:lane_assignment, :competition => @competition)
      delete :destroy, {:id => lane_assignment.to_param}
      expect(response).to redirect_to(competition_lane_assignments_path(@competition))
    end
  end

end
