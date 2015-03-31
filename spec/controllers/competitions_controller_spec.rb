require 'spec_helper'

describe CompetitionsController do
  before(:each) do
    @admin_user =FactoryGirl.create(:super_admin_user)
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
    it "assigns the event as @event" do
      get :new, {:event_id => @event.id}
      expect(assigns(:event)).to eq(@event)
    end
  end

  describe "GET edit" do
    it "assigns the requested competition as @competition" do
      competition = FactoryGirl.create(:competition)
      get :edit, {:id => competition.to_param}
      expect(assigns(:competition)).to eq(competition)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "can create a competition" do
        expect {
          post :create, {:event_id => @event.id, :competition => valid_attributes}
        }.to change(Competition, :count).by(1)
      end
      it "can create a Female gender_filter competition" do
        @comp = FactoryGirl.create(:competition)
        expect {
          post :create, {:event_id => @event.id, :competition => valid_attributes.merge({:competition_sources_attributes => [{:competition_id => @comp.id, :gender_filter => "Female"}]}) }
        }.to change(Competition, :count).by(1)
        expect(CompetitionSource.last.gender_filter).to eq("Female")
      end

      it "assigns a newly created competition as @competition" do
        post :create, {:event_id => @event.id, :competition => valid_attributes}
        expect(assigns(:competition)).to be_a(Competition)
        expect(assigns(:competition)).to be_persisted
      end

      it "redirects to the created competition's event" do
        post :create, {:event_id => @event.id, :competition => valid_attributes}
        expect(response).to redirect_to(event_path(@event))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competition).to receive(:valid?).and_return(false)
        allow_any_instance_of(Competition).to receive(:errors).and_return("anything")
        post :create, {:event_id => @event.id, :competition => {:name => "comp"}}
        expect(response).to render_template("new")
      end
      it "loads the event" do
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        post :create, {:event_id => @event.id, :competition => {:name => "comp"}}
        expect(assigns(:event)).to eq(@event)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested competition" do
        competition = FactoryGirl.create(:competition)
        # Assuming there are no other competitions in the database, this
        # specifies that the Competition created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Competition).to receive(:update_attributes).with({})
        put :update, {:id => competition.to_param, :competition => {'there' => 'params'}}
      end

      it "assigns the requested competition as @competition" do
        competition = FactoryGirl.create(:competition)
        put :update, {:id => competition.to_param, :competition => valid_attributes}
        expect(assigns(:competition)).to eq(competition)
      end

      it "redirects to the competition's event" do
        competition = FactoryGirl.create(:competition)
        put :update, {:id => competition.to_param, :competition => valid_attributes}
        expect(response).to redirect_to(event_path(competition.event))
      end
    end

    describe "with invalid params" do
      it "assigns the competition as @competition" do
        competition = FactoryGirl.create(:competition)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competition).to receive(:valid?).and_return(false)
        allow_any_instance_of(Competition).to receive(:errors).and_return("anything")
        put :update, {:id => competition.to_param, :competition => {:name => "fake"}}
        expect(assigns(:competition)).to eq(competition)
      end

      it "re-renders the 'edit' template" do
        competition = FactoryGirl.create(:competition)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competition).to receive(:valid?).and_return(false)
        allow_any_instance_of(Competition).to receive(:errors).and_return("anything")
        put :update, {:id => competition.to_param, :competition => {:name => "comp"}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested competition" do
      competition = FactoryGirl.create(:competition, :event => @event)
      expect {
        delete :destroy, {:id => competition.to_param}
      }.to change(Competition, :count).by(-1)
    end

    it "redirects to the event_categories list" do
      competition = FactoryGirl.create(:competition, :event => @event)
      delete :destroy, {:id => competition.to_param}
      expect(response).to redirect_to(event_path(@event))
    end
  end

  describe "POST lock" do
    it "locks the competition" do
      competition = FactoryGirl.create(:competition, :event => @event)
      post :lock, {:id => competition.to_param}
      competition.reload
      expect(competition.locked?).to eq(true)
    end
  end
  describe "DELETE lock" do
    it "unlocks the competition" do
      competition = FactoryGirl.create(:competition, event: @event, locked: true)
      delete :unlock, {:id => competition.to_param}
      competition.reload
      expect(competition.locked?).to eq(false)
    end
  end

  describe "POST publish" do
    it "publishes the competition results" do
      competition = FactoryGirl.create(:competition, event: @event, locked: true)
      post :publish, {:id => competition.to_param}
      competition.reload
      expect(competition.published?).to eq(true)
    end
  end
  describe "DELETE publish" do
    it "un-publishes the competition" do
      competition = FactoryGirl.create(:competition, event: @event, locked: true, published: true)
      delete :unpublish, {:id => competition.to_param}
      competition.reload
      expect(competition.published?).to eq(false)
    end
  end

  describe "when the competition is a distance competition, with time-results" do
    before(:each) do
      @competition = FactoryGirl.create(:timed_competition)
      expect(@competition.event_class).to eq("Shortest Time")
      @competitor = FactoryGirl.create(:event_competitor, :competition => @competition)
      @tr = FactoryGirl.create(:time_result, :competitor => @competitor)
    end
  end
end
