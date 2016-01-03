require 'spec_helper'

describe ConventionSetup::VolunteerOpportunitiesController do
  before do
    user = FactoryGirl.create(:convention_admin_user)
    sign_in user
  end

  def valid_attributes
    FactoryGirl.attributes_for(:volunteer_opportunity)
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read summary" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all volunteer opportunities as @voluntee_opportunities" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
      get :index, {}
      expect(response).to be_success
      expect(assigns(:volunteer_opportunities)).to eq([volunteer_opportunity])
    end
  end

  describe "GET new" do
    it "lists the new opportunity" do
      get :new
      expect(response).to be_success
      expect(assigns(:volunteer_opportunity)).to be_a_new(VolunteerOpportunity)
    end
  end

  describe "POST create" do
    it "creates a new VolunteerOpportunity" do
      expect do
        post :create, volunteer_opportunity: valid_attributes
      end.to change(VolunteerOpportunity, :count).by(1)
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(VolunteerOpportunity).to receive(:save).and_return(false)
        post :create, volunteer_opportunity: valid_attributes
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    it "updates the volunteer opportunity" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)

      expect do
        put :update, volunteer_opportunity: { description: "New description" }, id: volunteer_opportunity.id
      end.to change(VolunteerOpportunity, :count).by(0)

      expect(volunteer_opportunity.reload.description).to eq("New description")
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(VolunteerOpportunity).to receive(:save).and_return(false)
        put :update, volunteer_opportunity: { description: "New description" }, id: volunteer_opportunity.id
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "removes volunteer opportunity" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
      expect do
        delete :destroy, id: volunteer_opportunity.id
      end.to change(VolunteerOpportunity, :count).by(-1)
    end
  end
end
