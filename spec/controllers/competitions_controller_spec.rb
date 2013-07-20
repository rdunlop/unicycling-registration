require 'spec_helper'

describe CompetitionsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @event = FactoryGirl.create(:event)
    @competition = FactoryGirl.create(:competition)
  end

  # This should return the minimal set of attributes required to create a valid
  # Competitioon. As you add validations to Competitioon, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
    name: "Unlimited",
    event_id: @event.id
    }
  end



  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read competitions" do
      get :index, {:event_id => @event.id}
      response.should redirect_to(root_path)
    end
  end


  # /events/#/competitions
  describe "GET index" do
    it "assigns all event's competitions as @competitions" do
      competition = Competition.create! valid_attributes.merge({:event_id => @event.id})
      get :index, {:event_id => @event.id}
      assigns(:competitions).should eq([competition])
    end
    it "does not show competitions from other events" do
      competition = FactoryGirl.create(:competition)
      get :index, {:event_id => @event.id}
      assigns(:competitions).should eq(@event.competitions)
    end
    it "assigns a new competition" do
      competition = Competition.create! valid_attributes.merge({:event_id => @event.id})
      get :index, {:event_id => @event.id}
      assigns(:competition).should be_a_new(Competition)
    end
  end

  describe "GET show" do
    it "assigns the requested event_category as @event_category" do
      competition = Competition.create! valid_attributes
      get :show, {:id => competition.to_param}
      assigns(:competition).should eq(competition)
    end
  end

  describe "GET edit" do
    it "assigns the requested event_category as @event_category" do
      competition = Competition.create! valid_attributes
      get :edit, {:id => competition.to_param}
      assigns(:competition).should eq(competition)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Competition" do
        expect {
          post :create, {:event_id => @event.id, :competition => valid_attributes}
        }.to change(Competition, :count).by(1)
      end

      it "assigns a newly created competition as @competition" do
        post :create, {:event_id => @event.id, :competition => valid_attributes}
        assigns(:competition).should be_a(Competition)
        assigns(:competition).should be_persisted
      end

      it "redirects to the created competition" do
        post :create, {:event_id => @event.id, :competition => valid_attributes}
        response.should redirect_to(event_competitions_path(@event))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_category as @event_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        Competition.any_instance.stub(:save).and_return(false)
        post :create, {:event_id => @event.id, :competition => {}}
        assigns(:competition).should be_a_new(Competition)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Competition.any_instance.stub(:save).and_return(false)
        post :create, {:event_id => @event.id, :competition => {}}
        response.should render_template("index")
      end
      it "loads the event" do
        EventCategory.any_instance.stub(:save).and_return(false)
        post :create, {:event_id => @event.id, :competition => {}}
        assigns(:event).should == @event
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event_category" do
        competition = Competition.create! valid_attributes
        # Assuming there are no other competitions in the database, this
        # specifies that the Competition created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Competition.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => competition.to_param, :competition => {'these' => 'params'}}
      end

      it "assigns the requested event_category as @event_category" do
        competition = Competition.create! valid_attributes
        put :update, {:id => competition.to_param, :competition => valid_attributes}
        assigns(:competition).should eq(competition)
      end

      it "redirects to the event_category" do
        competition = Competition.create! valid_attributes
        put :update, {:id => competition.to_param, :competition => valid_attributes}
        response.should redirect_to(competition)
      end
    end

    describe "with invalid params" do
      it "assigns the event_category as @event_category" do
        competition = Competition.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Competition.any_instance.stub(:save).and_return(false)
        put :update, {:id => competition.to_param, :competition => {}}
        assigns(:competition).should eq(competition)
      end

      it "re-renders the 'edit' template" do
        competition = Competition.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Competition.any_instance.stub(:save).and_return(false)
        put :update, {:id => competition.to_param, :competition => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_category" do
      competition = FactoryGirl.create(:competition, :event => @event)
      expect {
        delete :destroy, {:id => competition.to_param}
      }.to change(Competition, :count).by(-1)
    end

    it "redirects to the event_categories list" do
      competition = FactoryGirl.create(:competition, :event => @event)
      event = competition.event
      delete :destroy, {:id => competition.to_param}
      response.should redirect_to(event_competitions_path(event))
    end
  end

  describe "POST lock" do
    it "locks the competition" do
      competition = FactoryGirl.create(:competition, :event => @event)
      post :lock, {:id => competition.to_param}
      competition.reload
      competition.locked?.should == true
    end
  end
  describe "DELETE lock" do
    it "unlocks the competition" do
      competition = FactoryGirl.create(:competition, :event => @event, :locked => true)
      delete :lock, {:id => competition.to_param}
      competition.reload
      competition.locked?.should == false
    end
  end
end
