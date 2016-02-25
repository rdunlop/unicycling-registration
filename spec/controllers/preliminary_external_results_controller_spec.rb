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
    { "competitor_id" => @competitor.id,
      "details" => "soomething",
      "status" => "active",
      "points" => 1
    }
  end

  describe "GET index" do
    it "assigns all external_results as @external_results" do
      external_result = FactoryGirl.create(:external_result, :preliminary, competitor: @competitor)
      get :index, competition_id: @competition.id
      expect(assigns(:external_results)).to eq([external_result])
    end
  end

  describe "GET edit" do
    it "assigns the requested external_result as @external_result" do
      external_result = FactoryGirl.create(:external_result, :preliminary)
      get :edit, id: external_result.to_param
      expect(assigns(:external_result)).to eq(external_result)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExternalResult" do
        expect do
          post :create, external_result: valid_attributes, competition_id: @competition.id
        end.to change(ExternalResult, :count).by(1)
      end

      it "assigns a newly created external_result as @external_result" do
        post :create, external_result: valid_attributes, competition_id: @competition.id
        expect(assigns(:external_result)).to be_a(ExternalResult)
        expect(assigns(:external_result)).to be_persisted
      end

      it "redirects to the created external_result" do
        post :create, external_result: valid_attributes, competition_id: @competition.id
        expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved external_result as @external_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        post :create, external_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id
        expect(assigns(:external_result)).to be_a_new(ExternalResult)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        post :create, external_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id
        expect(response).to render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested external_result" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        # Assuming there are no other external_results in the database, this
        # specifies that the ExternalResult created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(ExternalResult).to receive(:update_attributes).with("competitor_id" => "1")
        put :update, id: external_result.to_param, external_result: { "competitor_id" => "1" }
      end

      it "assigns the requested external_result as @external_result" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        put :update, id: external_result.to_param, external_result: valid_attributes
        expect(assigns(:external_result)).to eq(external_result)
      end

      it "redirects to the external_result index" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        put :update, id: external_result.to_param, external_result: valid_attributes
        expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns the external_result as @external_result" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        put :update, id: external_result.to_param, external_result: { "competitor_id" => "invalid value" }
        expect(assigns(:external_result)).to eq(external_result)
      end

      it "re-renders the 'edit' template" do
        external_result = FactoryGirl.create(:external_result, :preliminary)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        put :update, id: external_result.to_param, external_result: { "competitor_id" => "invalid value" }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested external_result" do
      external_result = FactoryGirl.create(:external_result, :preliminary)
      expect do
        delete :destroy, id: external_result.to_param
      end.to change(ExternalResult, :count).by(-1)
    end

    it "redirects to the external_results list" do
      external_result = FactoryGirl.create(:external_result, :preliminary, competitor: @competitor)
      delete :destroy, id: external_result.to_param
      expect(response).to redirect_to(competition_preliminary_external_results_path(@competition))
    end
  end

  describe "import_csv" do
    let(:test_file) { fixture_path + '/external_results.csv' }
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
        post :import_csv, competition_id: @competition.id, file: test_file
      end.to change(ExternalResult, :count).by 4
      expect(ExternalResult.preliminary.count).to eq(4)
    end
  end
end
