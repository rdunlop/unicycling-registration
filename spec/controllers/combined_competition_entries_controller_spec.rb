require 'spec_helper'

describe CombinedCompetitionEntriesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end
  let(:combined_competition) { FactoryGirl.create(:combined_competition) }

  let(:valid_attributes) { {
    :abbreviation => "M",
    :tie_breaker => true,
    :points_1 => 50,
    :points_2 => 50,
    :points_3 => 50,
    :points_4 => 50,
    :points_5 => 50,
    :points_6 => 50,
    :points_7 => 50,
    :points_8 => 50,
    :points_9 => 50,
    :points_10 => 50
  } }

  describe "GET index" do
    it "assigns all combined_competition_entries as @combined_competition_entries" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry, :combined_competition => combined_competition)
      get :index, {:combined_competition_id => combined_competition.id}
      expect(assigns(:combined_competition_entries)).to eq([combined_competition_entry])
    end
  end

  describe "GET new" do
    it "assigns a new combined_competition_entry as @combined_competition_entry" do
      get :new, {:combined_competition_id => combined_competition.id}
      expect(assigns(:combined_competition_entry)).to be_a_new(CombinedCompetitionEntry)
    end
  end

  describe "GET edit" do
    it "assigns the requested combined_competition_entry as @combined_competition_entry" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry)
      get :edit, {:id => combined_competition_entry.to_param, :combined_competition_id => combined_competition.id}
      expect(assigns(:combined_competition_entry)).to eq(combined_competition_entry)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CombinedCompetitionEntry" do
        expect {
          post :create, {:combined_competition_entry => valid_attributes, :combined_competition_id => combined_competition.id}
        }.to change(CombinedCompetitionEntry, :count).by(1)
      end

      it "redirects to the created combined_competition" do
        post :create, {:combined_competition_entry => valid_attributes, :combined_competition_id => combined_competition.id}
        expect(response).to redirect_to(combined_competition)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved combined_competition_entry as @combined_competition_entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetitionEntry).to receive(:save).and_return(false)
        post :create, {:combined_competition_entry => { "combined_competition_id" => "invalid value" }, :combined_competition_id => combined_competition.id}
        expect(assigns(:combined_competition_entry)).to be_a_new(CombinedCompetitionEntry)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetitionEntry).to receive(:save).and_return(false)
        post :create, {:combined_competition_entry => { "combined_competition_id" => "invalid value" }, :combined_competition_id => combined_competition.id}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested combined_competition_entry as @combined_competition_entry" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry)
        put :update, {:id => combined_competition_entry.to_param, :combined_competition_entry => valid_attributes, :combined_competition_id => combined_competition.id}
        expect(assigns(:combined_competition_entry)).to eq(combined_competition_entry)
      end

      it "redirects to the combined_competition_entry" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry, :combined_competition => combined_competition)
        put :update, {:id => combined_competition_entry.to_param, :combined_competition_entry => valid_attributes, :combined_competition_id => combined_competition.id}
        expect(response).to redirect_to(combined_competition)
      end
    end

    describe "with invalid params" do
      it "assigns the combined_competition_entry as @combined_competition_entry" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry, :combined_competition => combined_competition)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetitionEntry).to receive(:save).and_return(false)
        put :update, {:id => combined_competition_entry.to_param, :combined_competition_entry => { "combined_competition_id" => "invalid value" }, :combined_competition_id => combined_competition.id}
        expect(assigns(:combined_competition_entry)).to eq(combined_competition_entry)
      end

      it "re-renders the 'edit' template" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry, :combined_competition => combined_competition)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetitionEntry).to receive(:save).and_return(false)
        put :update, {:id => combined_competition_entry.to_param, :combined_competition_entry => { "combined_competition_id" => "invalid value" }, :combined_competition_id => combined_competition.id}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested combined_competition_entry" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry, :combined_competition => combined_competition)
      expect {
        delete :destroy, {:id => combined_competition_entry.to_param, :combined_competition_id => combined_competition.id}
      }.to change(CombinedCompetitionEntry, :count).by(-1)
    end

    it "redirects to the combined_competition_entries list" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry, :combined_competition => combined_competition)
      delete :destroy, {:id => combined_competition_entry.to_param, :combined_competition_id => combined_competition.id}
      expect(response).to redirect_to(combined_competition)
    end
  end

end
