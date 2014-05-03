require 'spec_helper'

describe CombinedCompetitionsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  let(:valid_attributes) { { "name" => "MyString" } }

  describe "GET index" do
    it "assigns all combined_competitions as @combined_competitions" do
      combined_competition = CombinedCompetition.create! valid_attributes
      get :index, {}
      expect(assigns(:combined_competitions)).to eq([combined_competition])
    end
  end

  describe "GET show" do
    it "assigns the requested combined_competition as @combined_competition" do
      combined_competition = CombinedCompetition.create! valid_attributes
      get :show, {:id => combined_competition.to_param}
      expect(assigns(:combined_competition)).to eq(combined_competition)
    end
  end

  describe "GET new" do
    it "assigns a new combined_competition as @combined_competition" do
      get :new, {}
      expect(assigns(:combined_competition)).to be_a_new(CombinedCompetition)
    end
  end

  describe "GET edit" do
    it "assigns the requested combined_competition as @combined_competition" do
      combined_competition = CombinedCompetition.create! valid_attributes
      get :edit, {:id => combined_competition.to_param}
      expect(assigns(:combined_competition)).to eq(combined_competition)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CombinedCompetition" do
        expect {
          post :create, {:combined_competition => valid_attributes}
        }.to change(CombinedCompetition, :count).by(1)
      end

      it "assigns a newly created combined_competition as @combined_competition" do
        post :create, {:combined_competition => valid_attributes}
        expect(assigns(:combined_competition)).to be_a(CombinedCompetition)
        expect(assigns(:combined_competition)).to be_persisted
      end

      it "redirects to the created combined_competition" do
        post :create, {:combined_competition => valid_attributes}
        expect(response).to redirect_to(CombinedCompetition.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved combined_competition as @combined_competition" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        post :create, {:combined_competition => { "name" => "invalid value" }}
        expect(assigns(:combined_competition)).to be_a_new(CombinedCompetition)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        post :create, {:combined_competition => { "name" => "invalid value" }}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        # Assuming there are no other combined_competitions in the database, this
        # specifies that the CombinedCompetition created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(CombinedCompetition).to receive(:update).with({ "name" => "MyString" })
        put :update, {:id => combined_competition.to_param, :combined_competition => { "name" => "MyString" }}
      end

      it "assigns the requested combined_competition as @combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        put :update, {:id => combined_competition.to_param, :combined_competition => valid_attributes}
        expect(assigns(:combined_competition)).to eq(combined_competition)
      end

      it "redirects to the combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        put :update, {:id => combined_competition.to_param, :combined_competition => valid_attributes}
        expect(response).to redirect_to(combined_competition)
      end
    end

    describe "with invalid params" do
      it "assigns the combined_competition as @combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        put :update, {:id => combined_competition.to_param, :combined_competition => { "name" => "invalid value" }}
        expect(assigns(:combined_competition)).to eq(combined_competition)
      end

      it "re-renders the 'edit' template" do
        combined_competition = CombinedCompetition.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        put :update, {:id => combined_competition.to_param, :combined_competition => { "name" => "invalid value" }}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested combined_competition" do
      combined_competition = CombinedCompetition.create! valid_attributes
      expect {
        delete :destroy, {:id => combined_competition.to_param}
      }.to change(CombinedCompetition, :count).by(-1)
    end

    it "redirects to the combined_competitions list" do
      combined_competition = CombinedCompetition.create! valid_attributes
      delete :destroy, {:id => combined_competition.to_param}
      expect(response).to redirect_to(combined_competitions_url)
    end
  end

end
