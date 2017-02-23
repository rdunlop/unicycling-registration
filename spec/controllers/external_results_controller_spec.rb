# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string(255)
#  points        :decimal(6, 3)    not null
#  created_at    :datetime
#  updated_at    :datetime
#  entered_by_id :integer          not null
#  entered_at    :datetime         not null
#  status        :string           not null
#  preliminary   :boolean          not null
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id) UNIQUE
#

require 'spec_helper'

describe ExternalResultsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
    @competition = FactoryGirl.create(:competition)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
  end

  # This should return the minimal set of attributes required to create a valid
  # ExternalResult. As you add validations to ExternalResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "competitor_id" => @competitor.id,
      "details" => "soomething",
      "status" => "active",
      "points" => 1
    }
  end

  describe "GET index" do
    it "shows all external_results" do
      FactoryGirl.create(:external_result, competitor: @competitor)
      get :index, params: { competition_id: @competition.id }
      assert_select "h1", "New Entered Points Result"

      assert_select "form", action: competition_external_results_path(@competition), method: "post" do
        assert_select "select#external_result_competitor_id", name: "external_result[competitor_id]"
        assert_select "input#external_result_details", name: "external_result[details]"
        assert_select "input#external_result_points", name: "external_result[points]"
      end
    end
  end

  describe "GET edit" do
    it "shows requested external_result form" do
      external_result = FactoryGirl.create(:external_result)
      get :edit, params: { id: external_result.to_param }
      assert_select "h1", "Editing points result"

      assert_select "form", action: external_result_path(external_result), method: "put" do
        assert_select "select#external_result_competitor_id", name: "external_result[competitor_id]"
        assert_select "input#external_result_details", name: "external_result[details]"
        assert_select "input#external_result_points", name: "external_result[points]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExternalResult" do
        expect do
          post :create, params: { external_result: valid_attributes, competition_id: @competition.id }
        end.to change(ExternalResult, :count).by(1)
      end

      it "redirects to the created external_result" do
        post :create, params: { external_result: valid_attributes, competition_id: @competition.id }
        expect(response).to redirect_to(competition_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        post :create, params: { external_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id }
        assert_select "h1", "New Entered Points Result"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested external_result" do
        external_result = FactoryGirl.create(:external_result)
        expect do
          put :update, params: { id: external_result.to_param, external_result: valid_attributes }
        end.to change{ external_result.reload.updated_at }
      end

      it "redirects to the external_result index" do
        external_result = FactoryGirl.create(:external_result)
        put :update, params: { id: external_result.to_param, external_result: valid_attributes }
        expect(response).to redirect_to(competition_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        external_result = FactoryGirl.create(:external_result)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        put :update, params: { id: external_result.to_param, external_result: { "competitor_id" => "invalid value" } }
        assert_select "h1", "Editing points result"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested external_result" do
      external_result = FactoryGirl.create(:external_result)
      expect do
        delete :destroy, params: { id: external_result.to_param }
      end.to change(ExternalResult, :count).by(-1)
    end

    it "redirects to the external_results list" do
      external_result = FactoryGirl.create(:external_result, competitor: @competitor)
      delete :destroy, params: { id: external_result.to_param }
      expect(response).to redirect_to(competition_external_results_path(@competition))
    end
  end
end
