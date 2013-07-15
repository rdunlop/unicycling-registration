require 'spec_helper'

describe EventCategoriesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @event = FactoryGirl.create(:event)
    @act = FactoryGirl.create(:age_group_type)
  end

  # This should return the minimal set of attributes required to create a valid
  # EventCategory. As you add validations to EventCategory, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
    name: "Unlimited",
    position: 2,
    age_group_type_id: @act.id
    }
  end



  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read event_categories" do
      get :index, {:event_id => @event.id}
      response.should redirect_to(root_path)
    end
  end


  describe "GET index" do
    it "assigns all event_categories as @event_categories" do
      event_category = EventCategory.create! valid_attributes.merge({:event_id => @event.id})
      get :index, {:event_id => @event.id}
      assigns(:event_categories).should eq(@event.event_categories)
    end
    it "does not show event choices from other events" do
      event_category = FactoryGirl.create(:event).event_categories.first
      get :index, {:event_id => @event.id}
      assigns(:event_categories).should eq(@event.event_categories)
    end
    it "assigns a new event_category" do
      event_category = EventCategory.create! valid_attributes.merge({:event_id => @event.id})
      get :index, {:event_id => @event.id}
      assigns(:event_category).should be_a_new(EventCategory)
    end
  end

  describe "GET show" do
    it "assigns the requested event_category as @event_category" do
      event_category = EventCategory.create! valid_attributes
      get :show, {:id => event_category.to_param}
      assigns(:event_category).should eq(event_category)
    end
  end

  describe "GET edit" do
    it "assigns the requested event_category as @event_category" do
      event_category = EventCategory.create! valid_attributes
      get :edit, {:id => event_category.to_param}
      assigns(:event_category).should eq(event_category)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventCategory" do
        expect {
          post :create, {:event_id => @event.id, :event_category => valid_attributes}
        }.to change(EventCategory, :count).by(1)
      end

      it "assigns a newly created event_category as @event_category" do
        post :create, {:event_id => @event.id, :event_category => valid_attributes}
        assigns(:event_category).should be_a(EventCategory)
        assigns(:event_category).should be_persisted
      end

      it "redirects to the created event_category" do
        post :create, {:event_id => @event.id, :event_category => valid_attributes}
        response.should redirect_to(event_event_categories_path(@event))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_category as @event_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        EventCategory.any_instance.stub(:save).and_return(false)
        post :create, {:event_id => @event.id, :event_category => {}}
        assigns(:event_category).should be_a_new(EventCategory)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        EventCategory.any_instance.stub(:save).and_return(false)
        post :create, {:event_id => @event.id, :event_category => {}}
        response.should render_template("index")
      end
      it "loads the event" do
        EventCategory.any_instance.stub(:save).and_return(false)
        post :create, {:event_id => @event.id, :event_category => {}}
        assigns(:event).should == @event
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event_category" do
        event_category = EventCategory.create! valid_attributes
        # Assuming there are no other event_categories in the database, this
        # specifies that the EventCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        EventCategory.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => event_category.to_param, :event_category => {'these' => 'params'}}
      end

      it "assigns the requested event_category as @event_category" do
        event_category = EventCategory.create! valid_attributes
        put :update, {:id => event_category.to_param, :event_category => valid_attributes}
        assigns(:event_category).should eq(event_category)
      end

      it "redirects to the event_category" do
        event_category = EventCategory.create! valid_attributes
        put :update, {:id => event_category.to_param, :event_category => valid_attributes}
        response.should redirect_to(event_category)
      end
    end

    describe "with invalid params" do
      it "assigns the event_category as @event_category" do
        event_category = EventCategory.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        EventCategory.any_instance.stub(:save).and_return(false)
        put :update, {:id => event_category.to_param, :event_category => {}}
        assigns(:event_category).should eq(event_category)
      end

      it "re-renders the 'edit' template" do
        event_category = EventCategory.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        EventCategory.any_instance.stub(:save).and_return(false)
        put :update, {:id => event_category.to_param, :event_category => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_category" do
      event_category = FactoryGirl.create(:event_category, :event => @event, :position => 2)
      expect {
        delete :destroy, {:id => event_category.to_param}
      }.to change(EventCategory, :count).by(-1)
    end

    it "redirects to the event_categories list" do
      event_category = FactoryGirl.create(:event_category, :event => @event, :position => 2)
      event = event_category.event
      delete :destroy, {:id => event_category.to_param}
      response.should redirect_to(event_event_categories_path(event))
    end
  end

  describe "GET sign_ups" do
    it "lists all of the currently sign-up registrants" do
      reg = FactoryGirl.create(:registrant)
      event_category = FactoryGirl.create(:event_category, :event => @event, :position => 2)
      FactoryGirl.create(:registrant_event_sign_up, :event => @event, :event_category => event_category, :signed_up => true, :registrant => reg)
      get :sign_ups, {:id => event_category.to_param}
      assigns(:registrants).should == [reg]
    end
  end
end
