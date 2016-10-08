require 'spec_helper'

describe Compete::CombinedCompetitionEntriesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end
  let(:competition) { FactoryGirl.create(:competition) }
  let(:combined_competition) { FactoryGirl.create(:combined_competition) }

  let(:valid_attributes) do
    {
      abbreviation: "M",
      competition_id: competition.id,
      tie_breaker: true,
      points_1: 50,
      points_2: 50,
      points_3: 50,
      points_4: 50,
      points_5: 50,
      points_6: 50,
      points_7: 50,
      points_8: 50,
      points_9: 50,
      points_10: 50
    }
  end

  describe "GET index" do
    it "shows all combined_competition_entries" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition)
      get :index, params: { combined_competition_id: combined_competition.id }

      assert_select "th", combined_competition_entry.to_s
    end
  end

  describe "GET new" do
    it "assigns a new combined_competition_entry as @combined_competition_entry" do
      get :new, params: { combined_competition_id: combined_competition.id }
      assert_select "form[action=?][method=?]", combined_competition_combined_competition_entries_path(combined_competition, locale: :en), "post" do
        assert_select "input#combined_competition_entry_abbreviation[name=?]", "combined_competition_entry[abbreviation]"
        assert_select "input#combined_competition_entry_tie_breaker[name=?]", "combined_competition_entry[tie_breaker]"
        assert_select "input#combined_competition_entry_points_1[name=?]", "combined_competition_entry[points_1]"
        assert_select "select#combined_competition_entry_competition_id[name=?]", "combined_competition_entry[competition_id]"
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested combined_competition_entry as @combined_competition_entry" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry)
      get :edit, params: { id: combined_competition_entry.to_param, combined_competition_id: combined_competition.id }

      assert_select "h1", "Editing calculation source"
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CombinedCompetitionEntry" do
        expect do
          post :create, params: { combined_competition_entry: valid_attributes, combined_competition_id: combined_competition.id }
        end.to change(CombinedCompetitionEntry, :count).by(1)
      end

      it "redirects to the created combined_competition" do
        post :create, params: { combined_competition_entry: valid_attributes, combined_competition_id: combined_competition.id }
        expect(response).to redirect_to(combined_competition_combined_competition_entries_path(combined_competition))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetitionEntry).to receive(:save).and_return(false)
        post :create, params: { combined_competition_entry: { "combined_competition_id" => "invalid value" }, combined_competition_id: combined_competition.id }
        assert_select "h1", "New calculation source"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the combined_competition_entry" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry)
        expect do
          put :update, params: { id: combined_competition_entry.to_param, combined_competition_entry: valid_attributes.merge(abbreviation: "T22"), combined_competition_id: combined_competition.id }
        end.to change { combined_competition_entry.reload.abbreviation }
      end

      it "redirects to the combined_competition_entry" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition)
        put :update, params: { id: combined_competition_entry.to_param, combined_competition_entry: valid_attributes, combined_competition_id: combined_competition.id }
        expect(response).to redirect_to(combined_competition_combined_competition_entries_path(combined_competition))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        combined_competition_entry = FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetitionEntry).to receive(:save).and_return(false)
        put :update, params: { id: combined_competition_entry.to_param, combined_competition_entry: { "combined_competition_id" => "invalid value" }, combined_competition_id: combined_competition.id }
        assert_select "h1", "Editing calculation source"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested combined_competition_entry" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition)
      expect do
        delete :destroy, params: { id: combined_competition_entry.to_param, combined_competition_id: combined_competition.id }
      end.to change(CombinedCompetitionEntry, :count).by(-1)
    end

    it "redirects to the combined_competition_entries list" do
      combined_competition_entry = FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition)
      delete :destroy, params: { id: combined_competition_entry.to_param, combined_competition_id: combined_competition.id }
      expect(response).to redirect_to(combined_competition)
    end
  end
end
