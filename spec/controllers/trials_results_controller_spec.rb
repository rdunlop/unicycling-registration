# == Schema Information
#
# Table name: trials_results
#
#  id            :bigint           not null, primary key
#  competitor_id :integer          not null
#  points        :integer          not null
#  minutes       :integer          not null
#  seconds       :integer          not null
#  details       :string
#  entered_at    :datetime         not null
#  entered_by_id :integer          not null
#  status        :string           not null
#  preliminary   :boolean          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_trials_results_on_competitor_id  (competitor_id) UNIQUE
#

require 'spec_helper'

describe TrialsResultsController do
  before do
    @admin_user = FactoryBot.create(:super_admin_user)
    sign_in @admin_user
    @competition = FactoryBot.create(:competition)
    @competitor = FactoryBot.create(:event_competitor, competition: @competition)
  end

  # This should return the minimal set of attributes required to create a valid
  # TrialsResult. As you add validations to TrialsResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "competitor_id" => @competitor.id,
      "status" => "active",
      "points" => 50,
      "minutes" => 45,
      "seconds" => 42 }
  end

  describe "GET index" do
    it "shows all trials_results" do
      FactoryBot.create(:trials_result, competitor: @competitor)
      get :index, params: { competition_id: @competition.id }
      assert_select "h1", "Enter New Trials Result"

      assert_select "form", action: competition_trials_results_path(@competition), method: "post" do
        assert_select "select#trials_result_competitor_id", name: "trials_result[competitor_id]"
        assert_select "input#trials_result_points", name: "trials_result[points]"
        assert_select "input#trials_result_minutes", name: "trials_result[points]"
        assert_select "input#trials_result_seconds", name: "trials_result[points]"
        assert_select "input#trials_result_details", name: "trials_result[details]"
        assert_select "select#trials_result_status", name: "trials_result[status]"
      end
    end
  end

  describe "GET edit" do
    it "shows requested trials_result form" do
      trials_result = FactoryBot.create(:trials_result)
      get :edit, params: { id: trials_result.to_param }
      assert_select "h1", "Editing Trials result"

      assert_select "form", action: trials_result_path(trials_result), method: "put" do
        assert_select "select#trials_result_competitor_id", name: "trials_result[competitor_id]"
        assert_select "input#trials_result_points", name: "trials_result[points]"
        assert_select "input#trials_result_minutes", name: "trials_result[minutes]"
        assert_select "input#trials_result_seconds", name: "trials_result[seconds]"
        assert_select "input#trials_result_details", name: "trials_result[details]"
        assert_select "select#trials_result_status", name: "trials_result[status]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TrialsResult" do
        expect do
          post :create, params: { trials_result: valid_attributes, competition_id: @competition.id }
        end.to change(TrialsResult, :count).by(1)
      end

      it "redirects to the created trials_result" do
        post :create, params: { trials_result: valid_attributes, competition_id: @competition.id }
        expect(response).to redirect_to(competition_trials_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TrialsResult).to receive(:save).and_return(false)
        post :create, params: { trials_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id }
        assert_select "h1", "Enter New Trials Result"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested trials_result" do
        trials_result = FactoryBot.create(:trials_result)
        expect do
          put :update, params: { id: trials_result.to_param, trials_result: valid_attributes }
        end.to change { trials_result.reload.updated_at }
      end

      it "redirects to the trials_result index" do
        trials_result = FactoryBot.create(:trials_result)
        put :update, params: { id: trials_result.to_param, trials_result: valid_attributes }
        expect(response).to redirect_to(competition_trials_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        trials_result = FactoryBot.create(:trials_result)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TrialsResult).to receive(:save).and_return(false)
        put :update, params: { id: trials_result.to_param, trials_result: { "competitor_id" => "invalid value" } }
        assert_select "h1", "Editing Trials result"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested trials_result" do
      trials_result = FactoryBot.create(:trials_result)
      expect do
        delete :destroy, params: { id: trials_result.to_param }
      end.to change(TrialsResult, :count).by(-1)
    end

    it "redirects to the trials_results list" do
      trials_result = FactoryBot.create(:trials_result, competitor: @competitor)
      delete :destroy, params: { id: trials_result.to_param }
      expect(response).to redirect_to(competition_trials_results_path(@competition))
    end
  end
end
