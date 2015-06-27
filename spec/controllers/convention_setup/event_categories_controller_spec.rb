require 'spec_helper'

describe ConventionSetup::EventCategoriesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @event = FactoryGirl.create(:event)
  end

  # This should return the minimal set of attributes required to create a valid
  # EventCategory. As you add validations to EventCategory, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "Unlimited"
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read event_categories" do
      get :index, event_id: @event.id
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    before do
      EventCategory.create! valid_attributes.merge(event_id: @event.id)
      get :index, event_id: @event.id
    end

    it "assigns all event_categories as @event_categories" do
      expect(assigns(:event_categories)).to eq(@event.event_categories)
    end

    it "does not show event choices from other events" do
      expect(assigns(:event_categories)).to eq(@event.event_categories)
    end

    it "assigns a new event_category" do
      expect(assigns(:event_category)).to be_a_new(EventCategory)
    end
  end

  describe "GET edit" do
    it "assigns the requested event_category as @event_category" do
      event_category = @event.event_categories.first
      get :edit, id: event_category.to_param
      expect(assigns(:event_category)).to eq(event_category)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventCategory" do
        expect do
          post :create, event_id: @event.id, event_category: valid_attributes
        end.to change(EventCategory, :count).by(1)
      end

      it "assigns a newly created event_category as @event_category" do
        post :create, event_id: @event.id, event_category: valid_attributes
        expect(assigns(:event_category)).to be_a(EventCategory)
        expect(assigns(:event_category)).to be_persisted
      end

      it "redirects to the created event_category" do
        post :create, event_id: @event.id, event_category: valid_attributes
        expect(response).to redirect_to(convention_setup_event_event_categories_path(@event))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_category as @event_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        post :create, event_id: @event.id, event_category: {name: "cat name"}
        expect(assigns(:event_category)).to be_a_new(EventCategory)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        post :create, event_id: @event.id, event_category: {name: "cat name"}
        expect(response).to render_template("index")
      end
      it "loads the event" do
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        post :create, event_id: @event.id, event_category: {name: "cat name"}
        expect(assigns(:event)).to eq(@event)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event_category" do
        event_category = @event.event_categories.first
        # Assuming there are no other event_categories in the database, this
        # specifies that the EventCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(EventCategory).to receive(:update_attributes).with({})
        put :update, id: event_category.to_param, event_category: {'these' => 'params'}
      end

      it "assigns the requested event_category as @event_category" do
        event_category = @event.event_categories.first
        put :update, id: event_category.to_param, event_category: valid_attributes
        expect(assigns(:event_category)).to eq(event_category)
      end

      it "redirects to the event" do
        event_category = @event.event_categories.first
        put :update, id: event_category.to_param, event_category: valid_attributes
        expect(response).to redirect_to(convention_setup_event_event_categories_path(event_category.event))
      end
    end

    describe "with invalid params" do
      it "assigns the event_category as @event_category" do
        event_category = @event.event_categories.first
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        put :update, id: event_category.to_param, event_category: {name: "cat name"}
        expect(assigns(:event_category)).to eq(event_category)
      end

      it "re-renders the 'edit' template" do
        event_category = @event.event_categories.first
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        put :update, id: event_category.to_param, event_category: {name: "cat name"}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_category" do
      event_category = FactoryGirl.create(:event_category, event: @event)
      expect do
        delete :destroy, id: event_category.to_param
      end.to change(EventCategory, :count).by(-1)
    end

    it "redirects to the event_categories list" do
      event_category = FactoryGirl.create(:event_category, event: @event)
      event = event_category.event
      delete :destroy, id: event_category.to_param
      expect(response).to redirect_to(convention_setup_event_event_categories_path(event))
    end
  end
end
