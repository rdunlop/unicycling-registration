require 'spec_helper'

describe ConventionSetup::EventsController do
  before do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
    @category = FactoryGirl.create(:category)
  end

  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "Event Name"
    }
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read events" do
      get :index, {:category_id => @category.id}
      response.should redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all events as @events" do
      event = FactoryGirl.create(:event, :category => @category)
      event2 = FactoryGirl.create(:event)
      get :index, {:category_id => @category.id}
      assigns(:events).should eq([event])
      assigns(:event).should be_a_new(Event)
      assigns(:category).should eq(@category)
    end
  end

  describe "GET edit" do
    it "assigns the requested event as @event" do
      event = FactoryGirl.create(:event, :category => @category)
      get :edit, {:id => event.to_param}
      assigns(:event).should eq(event)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, {:event => valid_attributes, :category_id => @category.id}
        }.to change(Event, :count).by(1)
      end

      it "assigns a newly created event as @event" do
        post :create, {:event => valid_attributes, :category_id => @category.id}
        assigns(:event).should be_a(Event)
        assigns(:event).should be_persisted
      end

      it "redirects to the created event" do
        post :create, {:event => valid_attributes, :category_id => @category.id}
        response.should redirect_to(convention_setup_category_events_path(@category))
      end

      it "doesn't create a category if one is supplied" do
        post :create, {
          :category_id => @category.id,
          :event => {:name => "Sample Event",
                     :event_categories_attributes => [
                       {
                         :name => "The Categorie",
                         :position => 1
                       }] }}
        ev = Event.last
        ev.event_categories.first.name.should == "The Categorie"
        ev.event_categories.count.should == 1
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, {:event => {:name => "event"}, :category_id => @category.id}
        assigns(:event).should be_a_new(Event)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, {:event => {:name => "event"}, :category_id => @category.id}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event" do
        event = FactoryGirl.create(:event)
        # Assuming there are no other events in the database, this
        # specifies that the Event created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Event.any_instance.should_receive(:update_attributes).with({})
        put :update, {:id => event.to_param, :event => {'these' => 'params'}}
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        put :update, {:id => event.to_param, :event => valid_attributes}
        assigns(:event).should eq(event)
      end

      it "redirects to the event" do
        event = FactoryGirl.create(:event, :category => @category)
        put :update, {:id => event.to_param, :event => valid_attributes}
        response.should redirect_to(convention_setup_category_events_path(@category))
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, {:id => event.to_param, :event => {:name => "event"}}
        assigns(:event).should eq(event)
      end

      it "re-renders the 'edit' template" do
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, {:id => event.to_param, :event => {:name => "event"}}
        response.should render_template("edit")
      end
    end
    describe "with nested event_choices" do
      before(:each) do
        @event = FactoryGirl.create(:event)
      end
      it "accepts nested attributes" do
        expect {
          put :update, {:id => @event.to_param, :event => {
            :event_choices_attributes => [
              {
                :cell_type => "boolean",
                :label => "My event Choice",
                :multiple_values => "m2",
                :position => 1
              }] }}
        }.to change(EventChoice, :count).by(1)
        ec = EventChoice.last
        ec.cell_type.should == "boolean"
        ec.label.should == "My event Choice"
        ec.multiple_values.should == "m2"
        ec.position.should == 1
      end

      it "accepts nested attributes" do
        put :update, {:id => @event.to_param, :event => {
          :event_choices_attributes => [
            {
              :cell_type => "boolean",
              :label => "My event Choice",
              :multiple_values => "m2",
              :position => 1
            }] }}
        ec = EventChoice.last

        expect {
          put :update, {:id => @event.to_param, :event => {
            :event_choices_attributes => [
              {
                :cell_type => ec.cell_type,
                :label => "new Label",
                :multiple_values => ec.multiple_values,
                :position => ec.position,
                :id => ec.id
              }] }}
        }.to change(EventChoice, :count).by(0)
        ec.reload
        ec.label.should == "new Label"
      end
    end

    describe "with nested event_categories" do
      before(:each) do
        @event = FactoryGirl.create(:event)
      end
      it "can update event_categories" do
        ecat = @event.event_categories.last

        expect {
          put :update, {:id => @event.to_param, :event => {
            :name => "Sample Event",
            :event_categories_attributes => [
              {
                :name => "New Name",
                :position => ecat.position,
                :id => ecat.id
              }] }}
        }.to change(EventCategory, :count).by(0)
        ecat.reload
        ecat.name.should == "New Name"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event" do
      event = FactoryGirl.create(:event)
      expect {
        delete :destroy, {:id => event.to_param}
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      event = FactoryGirl.create(:event, :category => @category)
      delete :destroy, {:id => event.to_param}
      response.should redirect_to(convention_setup_category_events_path(@category))
    end
  end
end
