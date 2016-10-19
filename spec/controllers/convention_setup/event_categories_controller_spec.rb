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
      get :index, params: { event_id: @event.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    before do
      EventCategory.create! valid_attributes.merge(event_id: @event.id)
      get :index, params: { event_id: @event.id }
    end

    it "shows all event_categories" do
      assert_select "tr.item", 2
      assert_select "td", "Unlimited"
    end

    it "shows a new event_category form" do
      assert_select "form", action: convention_setup_event_event_categories_path(@event), method: "post" do
        assert_select "input#event_category_name", name: "event_category[name]"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested event_category form" do
      event_category = @event.event_categories.first
      get :edit, params: { id: event_category.to_param }

      assert_select "form", action: convention_setup_event_category_path(event_category), method: "put" do
        assert_select "input#event_category_name", name: "event_category[name]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventCategory" do
        expect do
          post :create, params: { event_id: @event.id, event_category: valid_attributes }
        end.to change(EventCategory, :count).by(1)
      end

      it "redirects to the created event_category" do
        post :create, params: { event_id: @event.id, event_category: valid_attributes }
        expect(response).to redirect_to(convention_setup_event_event_categories_path(@event))
      end
    end

    describe "with invalid params" do
      it "does not create a new event_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        expect do
          post :create, params: { event_id: @event.id, event_category: {name: "cat name"} }
        end.not_to change(EventCategory, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        post :create, params: { event_id: @event.id, event_category: {name: "cat name"} }
        assert_select "h3", "New event category"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the event_category" do
        event_category = @event.event_categories.first
        expect do
          put :update, params: { id: event_category.to_param, event_category: valid_attributes.merge(name: "Hi There") }
        end.to change { event_category.reload.name }
      end

      it "redirects to the event" do
        event_category = @event.event_categories.first
        put :update, params: { id: event_category.to_param, event_category: valid_attributes }
        expect(response).to redirect_to(convention_setup_event_event_categories_path(event_category.event))
      end
    end

    describe "with invalid params" do
      it "does not update the event_category" do
        event_category = @event.event_categories.first
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: event_category.to_param, event_category: {name: "cat name"} }
        end.not_to change { event_category.reload.name }
      end

      it "re-renders the 'edit' template" do
        event_category = @event.event_categories.first
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventCategory).to receive(:save).and_return(false)
        put :update, params: { id: event_category.to_param, event_category: {name: "cat name"} }
        assert_select "h1", "Editing Event Category"
      end
    end
  end

  describe "PUT update_row_order" do
    let(:event) { FactoryGirl.create(:event) }
    let!(:event_category_1) { event.event_categories.first }
    let!(:event_category_2) { FactoryGirl.create(:event_category, event: event) }

    it "updates the order" do
      put :update_row_order, params: { event_id: event.to_param, id: event_category_1.to_param, row_order_position: 1 }
      expect(event_category_2.reload.position).to eq(1)
      expect(event_category_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_category" do
      event_category = FactoryGirl.create(:event_category, event: @event)
      expect do
        delete :destroy, params: { id: event_category.to_param }
      end.to change(EventCategory, :count).by(-1)
    end

    it "redirects to the event_categories list" do
      event_category = FactoryGirl.create(:event_category, event: @event)
      event = event_category.event
      delete :destroy, params: { id: event_category.to_param }
      expect(response).to redirect_to(convention_setup_event_event_categories_path(event))
    end
  end
end
