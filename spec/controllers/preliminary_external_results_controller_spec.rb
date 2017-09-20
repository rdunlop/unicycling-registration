require 'spec_helper'

describe PreliminaryExternalResultsController do
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
    {
      competitor_id: @competitor.id,
      details: "soomething",
      status: "active",
      points: 1
    }
  end

  describe "GET index" do
    it "shows all external_results" do
      external_result = FactoryGirl.create(:external_result, :preliminary, competitor: @competitor, details: "My details")
      get :index, params: { competition_id: @competition.id }

      assert_select "h1", "Data Recording Form - Entry Form (External Results)"
      assert_select "td", external_result.details
    end
  end

  describe "POST approve" do
    it "redirects" do
      # external_result = FactoryGirl.create(:external_result, :preliminary, competitor: @competitor, details: "My details")
      post :approve, params: { competition_id: @competition.id }
      expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
    end
  end

  describe "GET edit" do
    it "assigns the requested external_result as @external_result" do
      external_result = FactoryGirl.create(:external_result, :preliminary)
      get :edit, params: { id: external_result.to_param }
      assert_select "h1", "Editing points result"
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
        expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "does not create external_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        expect do
          post :create, params: { external_result: { competitor_id: "invalid value" }, competition_id: @competition.id }
        end.not_to change(ExternalResult, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        post :create, params: { external_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id }
        assert_select "h1", "Data Recording Form - Entry Form (External Results)"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the external_result" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        expect do
          put :update, params: { id: external_result.to_param, external_result: valid_attributes }
        end.to change { external_result.reload.details }
      end

      it "redirects to the external_result index" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        put :update, params: { id: external_result.to_param, external_result: valid_attributes }
        expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "does not update the external_result" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: external_result.to_param, external_result: { competitor_id: "invalid value" } }
        end.not_to change { external_result.reload.details }
      end

      it "re-renders the 'edit' template" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        put :update, params: { id: external_result.to_param, external_result: { "competitor_id" => "invalid value" } }
        assert_select "h1", "Editing points result"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested external_result" do
      external_result = FactoryGirl.create(:external_result, :preliminary)
      expect do
        delete :destroy, params: { id: external_result.to_param }
      end.to change(ExternalResult, :count).by(-1)
    end

    it "redirects to the external_results list" do
      external_result = FactoryGirl.create(:external_result, :preliminary, competitor: @competitor)
      delete :destroy, params: { id: external_result.to_param }
      expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
    end
  end

  describe "import_csv" do
    let(:test_file_name) { fixture_path + '/external_results.csv' }
    let(:test_file) { Rack::Test::UploadedFile.new(test_file_name, "text/plain") }
    before do
      registrant1 = FactoryGirl.create(:competitor, bib_number: 101)
      registrant2 = FactoryGirl.create(:competitor, bib_number: 102)
      registrant3 = FactoryGirl.create(:competitor, bib_number: 103)
      registrant4 = FactoryGirl.create(:competitor, bib_number: 104)
      comp1 = FactoryGirl.create(:event_competitor, competition: @competition)
      comp2 = FactoryGirl.create(:event_competitor, competition: @competition)
      comp3 = FactoryGirl.create(:event_competitor, competition: @competition)
      comp4 = FactoryGirl.create(:event_competitor, competition: @competition)
      comp1.members.first.update_attribute(:registrant, registrant1)
      comp2.members.first.update_attribute(:registrant, registrant2)
      comp3.members.first.update_attribute(:registrant, registrant3)
      comp4.members.first.update_attribute(:registrant, registrant4)
    end

    it "creates entries" do
      expect do
        post :import_csv, params: { competition_id: @competition.id, file: test_file }
      end.to change(ExternalResult, :count).by 4
      expect(ExternalResult.preliminary.count).to eq(4)
    end
  end
end
