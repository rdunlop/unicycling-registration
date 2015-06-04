require 'spec_helper'

describe ExternalResultsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
    @competition = FactoryGirl.create(:competition)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
  end

  # This should return the minimal set of attributes required to create a valid
  # ExternalResult. As you add validations to ExternalResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "competitor_id" =>  @competitor.id,
      "details" => "soomething",
      "points" => 1
    }
  end

  describe "GET index" do
    it "assigns all external_results as @external_results" do
      external_result = ExternalResult.create! valid_attributes
      get :index, {competition_id: @competition.id}
      expect(assigns(:external_results)).to eq([external_result])
    end
  end

  describe "GET edit" do
    it "assigns the requested external_result as @external_result" do
      external_result = ExternalResult.create! valid_attributes
      get :edit, {id: external_result.to_param}
      expect(assigns(:external_result)).to eq(external_result)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExternalResult" do
        expect {
          post :create, {external_result: valid_attributes, competition_id: @competition.id}
        }.to change(ExternalResult, :count).by(1)
      end

      it "assigns a newly created external_result as @external_result" do
        post :create, {external_result: valid_attributes, competition_id: @competition.id}
        expect(assigns(:external_result)).to be_a(ExternalResult)
        expect(assigns(:external_result)).to be_persisted
      end

      it "redirects to the created external_result" do
        post :create, {external_result: valid_attributes, competition_id: @competition.id}
        expect(response).to redirect_to(competition_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved external_result as @external_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        post :create, {external_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id}
        expect(assigns(:external_result)).to be_a_new(ExternalResult)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        post :create, {external_result: { "competitor_id" => "invalid value" }, competition_id: @competition.id}
        expect(response).to render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested external_result" do
        external_result = ExternalResult.create! valid_attributes
        # Assuming there are no other external_results in the database, this
        # specifies that the ExternalResult created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(ExternalResult).to receive(:update_attributes).with({ "competitor_id" => "1" })
        put :update, {id: external_result.to_param, external_result: { "competitor_id" => "1" }}
      end

      it "assigns the requested external_result as @external_result" do
        external_result = ExternalResult.create! valid_attributes
        put :update, {id: external_result.to_param, external_result: valid_attributes}
        expect(assigns(:external_result)).to eq(external_result)
      end

      it "redirects to the external_result index" do
        external_result = ExternalResult.create! valid_attributes
        put :update, {id: external_result.to_param, external_result: valid_attributes}
        expect(response).to redirect_to(competition_external_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns the external_result as @external_result" do
        external_result = ExternalResult.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        put :update, {id: external_result.to_param, external_result: { "competitor_id" => "invalid value" }}
        expect(assigns(:external_result)).to eq(external_result)
      end

      it "re-renders the 'edit' template" do
        external_result = ExternalResult.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalResult).to receive(:save).and_return(false)
        put :update, {id: external_result.to_param, external_result: { "competitor_id" => "invalid value" }}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested external_result" do
      external_result = ExternalResult.create! valid_attributes
      expect {
        delete :destroy, {id: external_result.to_param}
      }.to change(ExternalResult, :count).by(-1)
    end

    it "redirects to the external_results list" do
      external_result = ExternalResult.create! valid_attributes
      delete :destroy, {id: external_result.to_param}
      expect(response).to redirect_to(competition_external_results_path(@competition))
    end
  end
end
