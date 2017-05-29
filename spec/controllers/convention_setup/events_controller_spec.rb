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
      get :index, params: { category_id: @category.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "shows all events" do
      event = FactoryGirl.create(:event, category: @category)
      FactoryGirl.create(:event)
      get :index, params: { category_id: @category.id }

      assert_select "td", event.name

      # new form
      assert_select "form", action: convention_setup_category_events_path(@category), method: "post" do
        assert_select "input#event_name", name: "event[name]"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested event" do
      event = FactoryGirl.create(:event, category: @category)
      get :edit, params: { id: event.to_param }
      assert_select "form", action: convention_setup_event_path(event), method: "post" do
        assert_select "select#event_category_id", name: "event[category_id]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Event" do
        expect do
          post :create, params: { event: valid_attributes, category_id: @category.id }
        end.to change(Event, :count).by(1)
      end

      it "creates a new expense_item if cost is set" do
        expect do
          post :create, params: { event: valid_attributes.merge(cost: 1), category_id: @category.id }
        end.to change(ExpenseItem, :count).by(1)
      end

      it "redirects to the created event" do
        post :create, params: { event: valid_attributes, category_id: @category.id }
        expect(response).to redirect_to(convention_setup_category_events_path(@category))
      end

      it "doesn't create a category if one is supplied" do
        post :create, params: { category_id: @category.id,
                                event: {name: "Sample Event",
                                        event_categories_attributes: [
                                          {
                                            name: "The Categorie"
                                          }
                                        ] } }
        ev = Event.last
        expect(ev.event_categories.first.name).to eq("The Categorie")
        expect(ev.event_categories.count).to eq(1)
      end
    end

    describe "with invalid params" do
      it "does not create event" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        expect do
          post :create, params: { event: {name: "event"}, category_id: @category.id }
        end.not_to change(Event, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        post :create, params: { event: {name: "event"}, category_id: @category.id }

        assert_select "h1", "Events in Category: #{@category}"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event as @event" do
        event = FactoryGirl.create(:event)
        expect do
          put :update, params: { id: event.to_param, event: valid_attributes.merge(name: "Naaa") }
        end.to change { event.reload.name }
      end

      it "redirects to the event" do
        event = FactoryGirl.create(:event, category: @category)
        put :update, params: { id: event.to_param, event: valid_attributes }
        expect(response).to redirect_to(convention_setup_category_events_path(@category))
      end
    end

    describe "with invalid params" do
      it "does not update the event" do
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: event.to_param, event: {name: "event"} }
        end.not_to change { event.reload.name }
      end

      it "re-renders the 'edit' template" do
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        put :update, params: { id: event.to_param, event: {name: "event"} }

        assert_select "h1", "Editing event"
      end
    end
    describe "with nested event_choices" do
      before(:each) do
        @event = FactoryGirl.create(:event)
      end
      it "accepts nested attributes" do
        expect do
          put :update, params: { id: @event.to_param, event: {
            event_choices_attributes: [
              {
                cell_type: "boolean",
                label: "My event Choice",
                multiple_values: "m2"
              }
            ]
          } }
        end.to change(EventChoice, :count).by(1)
        ec = EventChoice.last
        expect(ec.cell_type).to eq("boolean")
        expect(ec.label).to eq("My event Choice")
        expect(ec.multiple_values).to eq("m2")
        expect(ec.position).to eq(1)
      end

      it "accepts nested attributes" do
        put :update, params: { id: @event.to_param, event: {
          event_choices_attributes: [
            {
              cell_type: "boolean",
              label: "My event Choice",
              multiple_values: "m2"
            }
          ]
        } }
        ec = EventChoice.last

        expect do
          put :update, params: { id: @event.to_param, event: {
            event_choices_attributes: [
              {
                cell_type: ec.cell_type,
                label: "new Label",
                multiple_values: ec.multiple_values,
                id: ec.id
              }
            ]
          } }
        end.to change(EventChoice, :count).by(0)
        ec.reload
        expect(ec.label).to eq("new Label")
      end
    end

    describe "with nested event_categories" do
      before(:each) do
        @event = FactoryGirl.create(:event)
      end
      it "can update event_categories" do
        ecat = @event.event_categories.last

        expect do
          put :update, params: { id: @event.to_param, event: {
            name: "Sample Event",
            event_categories_attributes: [
              {
                name: "New Name",
                id: ecat.id
              }
            ]
          } }
        end.to change(EventCategory, :count).by(0)
        ecat.reload
        expect(ecat.name).to eq("New Name")
      end
    end
  end

  describe "PUT update_row_order" do
    let(:category) { FactoryGirl.create(:category) }
    let!(:event_1) { FactoryGirl.create(:event, category: category) }
    let!(:event_2) { FactoryGirl.create(:event, category: category) }

    it "updates the order" do
      put :update_row_order, params: { category_id: category.to_param, id: event_1.to_param, row_order_position: 1 }
      expect(event_2.reload.position).to eq(1)
      expect(event_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event" do
      event = FactoryGirl.create(:event)
      expect do
        delete :destroy, params: { id: event.to_param }
      end.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      event = FactoryGirl.create(:event, category: @category)
      delete :destroy, params: { id: event.to_param }
      expect(response).to redirect_to(convention_setup_category_events_path(@category))
    end
  end
end
