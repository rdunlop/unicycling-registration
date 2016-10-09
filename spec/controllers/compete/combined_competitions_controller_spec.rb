require 'spec_helper'

describe Compete::CombinedCompetitionsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  let(:valid_attributes) { { name: "MyString", calculation_mode: 'default' } }

  describe "GET index" do
    it "shows all combined_competitions" do
      combined_competition = CombinedCompetition.create! valid_attributes
      get :index
      assert_select "tr>td", text: combined_competition.name.to_s, count: 1
    end
  end

  describe "GET new" do
    it "shows a new combined_competition form" do
      get :new
      assert_select "form[action=?][method=?]", combined_competitions_path(locale: :en), "post" do
        assert_select "input#combined_competition_name[name=?]", "combined_competition[name]"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested combined_competition" do
      combined_competition = CombinedCompetition.create! valid_attributes
      get :edit, params: { id: combined_competition.to_param }
      assert_select "form[action=?][method=?]", combined_competition_path(combined_competition, locale: :en), "post" do
        assert_select "input#combined_competition_name[name=?]", "combined_competition[name]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CombinedCompetition" do
        expect do
          post :create, params: { combined_competition: valid_attributes }
        end.to change(CombinedCompetition, :count).by(1)
      end

      it "redirects to the created combined_competition" do
        post :create, params: { combined_competition: valid_attributes }
        expect(response).to redirect_to(combined_competition_combined_competition_entries_path(CombinedCompetition.last))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        post :create, params: { combined_competition: { "name" => "invalid value" } }

        assert_select "h1", "New Overall Champion Calculator"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested combined_competition as @combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        expect do
          put :update, params: { id: combined_competition.to_param, combined_competition: valid_attributes.merge(name: "Hello") }
        end.to change{ combined_competition.reload.name }
      end

      it "redirects to the combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        put :update, params: { id: combined_competition.to_param, combined_competition: valid_attributes }
        expect(response).to redirect_to(combined_competitions_path)
      end
    end

    describe "with invalid params" do
      it "assigns the combined_competition as @combined_competition" do
        combined_competition = CombinedCompetition.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: combined_competition.to_param, combined_competition: { "name" => "invalid value" } }
        end.not_to change { combined_competition.reload.name }
      end

      it "re-renders the 'edit' template" do
        combined_competition = CombinedCompetition.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CombinedCompetition).to receive(:save).and_return(false)
        put :update, params: { id: combined_competition.to_param, combined_competition: { "name" => "invalid value" } }

        assert_select "h1", "Editing Overall Champion Calculator"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested combined_competition" do
      combined_competition = CombinedCompetition.create! valid_attributes
      expect do
        delete :destroy, params: { id: combined_competition.to_param }
      end.to change(CombinedCompetition, :count).by(-1)
    end

    it "redirects to the combined_competitions list" do
      combined_competition = CombinedCompetition.create! valid_attributes
      delete :destroy, params: { id: combined_competition.to_param }
      expect(response).to redirect_to(combined_competitions_url)
    end
  end
end
