require 'spec_helper'

describe CompetitionSetup::CompetitionsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
    @event = FactoryGirl.create(:event)
    @event_category = @event.event_categories.first
  end

  # This should return the minimal set of attributes required to create a valid
  # Competitioon. As you add validations to Competitioon, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "Unlimited",
      award_title_name: "10k Unlimited",
      scoring_class: "Freestyle"
    }
  end

  describe "GET new" do
    it "shows new competition event form" do
      get :new, params: { event_id: @event.id }

      assert_select "h1", "New #{@event} Competition"
    end

    describe "with a copy_from argument" do
      it "sets the arguments from an existing competition" do
        first_competition = FactoryGirl.create(:competition)
        get :new, params: { event_id: @event.id, copy_from: first_competition.id }
        assert_select "input[type='text'][value=?]", first_competition.name
      end
    end
  end

  describe "GET edit" do
    it "shows the requested competition form" do
      competition = FactoryGirl.create(:competition, event: @event)
      get :edit, params: { id: competition.to_param }

      assert_select "h1", "Editing #{@event} #{competition}"
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "can create a competition" do
        expect do
          post :create, params: { event_id: @event.id, competition: valid_attributes }
        end.to change(Competition, :count).by(1)
      end
      it "can create a Female gender_filter competition" do
        @comp = FactoryGirl.create(:competition)
        expect do
          post :create, params: { event_id: @event.id, competition: valid_attributes.merge(competition_sources_attributes: [{competition_id: @comp.id, gender_filter: "Female"}]) }
        end.to change(Competition, :count).by(1)
        expect(CompetitionSource.last.gender_filter).to eq("Female")
      end

      it "redirects to the competition_setup path" do
        post :create, params: { event_id: @event.id, competition: valid_attributes }
        expect(response).to redirect_to(competition_setup_path)
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competition).to receive(:valid?).and_return(false)
        post :create, params: { event_id: @event.id, competition: {name: "comp"} }

        assert_select "h1", "New #{@event} Competition"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested competition" do
        competition = FactoryGirl.create(:competition)
        expect do
          put :update, params: { id: competition.to_param, competition: valid_attributes.merge(name: "test Name") }
        end.to change { competition.reload.name }
      end

      it "redirects to the competition" do
        competition = FactoryGirl.create(:competition)
        put :update, params: { id: competition.to_param, competition: valid_attributes }
        expect(response).to redirect_to(competition)
      end
    end

    describe "with invalid params" do
      it "assigns the competition as @competition" do
        competition = FactoryGirl.create(:competition)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competition).to receive(:valid?).and_return(false)
        expect do
          put :update, params: { id: competition.to_param, competition: {name: "fake"} }
        end.not_to change { competition.reload.name }
      end

      it "re-renders the 'edit' template" do
        competition = FactoryGirl.create(:competition, event: @event)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competition).to receive(:valid?).and_return(false)
        put :update, params: { id: competition.to_param, competition: {name: "comp"} }

        assert_select "h1", "Editing #{@event} comp" # comp from update args
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested competition" do
      competition = FactoryGirl.create(:competition, event: @event)
      expect do
        delete :destroy, params: { id: competition.to_param }
      end.to change(Competition, :count).by(-1)
    end

    it "redirects to the competition_setup_path" do
      competition = FactoryGirl.create(:competition, event: @event)
      delete :destroy, params: { id: competition.to_param }
      expect(response).to redirect_to(competition_setup_path)
    end
  end
end
