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
    it "shows all volunteer opportunities" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
      get :index
      expect(response).to be_success
      assert_select "h1", "Volunteer Opportunities"
      assert_select "td", volunteer_opportunity.description
    end
  end

  describe "GET new" do
    it "lists the new opportunity" do
      get :new
      expect(response).to be_success

      assert_select "form#new_volunteer_opportunity", action: convention_setup_volunteer_opportunities_path, method: "post" do
        assert_select "input#volunteer_opportunity_description", name: "volunteer_opportunity[description]"
      end
    end
  end

  describe "POST create" do
    it "creates a new VolunteerOpportunity" do
      expect do
        post :create, params: { volunteer_opportunity: valid_attributes }
      end.to change(VolunteerOpportunity, :count).by(1)
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(VolunteerOpportunity).to receive(:save).and_return(false)
        post :create, params: { volunteer_opportunity: valid_attributes }
        assert_select "h1", "New Volunteer Role"
      end
    end
  end

  describe "PUT update" do
    it "updates the volunteer opportunity" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)

      expect do
        put :update, params: { volunteer_opportunity: { description: "New description" }, id: volunteer_opportunity.id }
      end.to change(VolunteerOpportunity, :count).by(0)

      expect(volunteer_opportunity.reload.description).to eq("New description")
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(VolunteerOpportunity).to receive(:save).and_return(false)
        put :update, params: { volunteer_opportunity: { description: "New description" }, id: volunteer_opportunity.id }

        assert_select "h1", "Edit Volunteer Role"
      end
    end
  end

  describe "PUT update_row_order" do
    let!(:volunteer_opportunity_1) { FactoryGirl.create(:volunteer_opportunity) }
    let!(:volunteer_opportunity_2) { FactoryGirl.create(:volunteer_opportunity) }

    it "updates the order" do
      put :update_row_order, params: { id: volunteer_opportunity_1.to_param, row_order_position: 1 }
      expect(volunteer_opportunity_2.reload.position).to eq(1)
      expect(volunteer_opportunity_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "removes volunteer opportunity" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
      expect do
        delete :destroy, params: { id: volunteer_opportunity.id }
      end.to change(VolunteerOpportunity, :count).by(-1)
    end
  end
end
