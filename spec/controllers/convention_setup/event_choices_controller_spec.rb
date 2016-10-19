require 'spec_helper'

describe ConventionSetup::EventChoicesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @event = FactoryGirl.create(:event)
  end

  # This should return the minimal set of attributes required to create a valid
  # EventChoice. As you add validations to EventChoice, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      cell_type: "boolean",
      optional: false,
      optional_if_event_choice_id: nil,
      required_if_event_choice_id: nil,
      "translations_attributes" => {
        "1" => {
          "id" => "",
          "locale" => "en",
          "label" => "label_en",
          "tooltip" => "tool_en"
        }, "2" => {
          "id" => "",
          "locale" => "fr",
          "label" => "label_fr",
          "tooltip" => "tool_fr"}
      }
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read event_choices" do
      get :index, params: { event_id: @event.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "shows all event_choices" do
      ec = EventChoice.create! valid_attributes.merge(event_id: @event.id)
      get :index, params: { event_id: @event.id }

      assert_select "td", ec.label
    end

    it "shows a new event_choice form" do
      EventChoice.create! valid_attributes.merge(event_id: @event.id)
      get :index, params: { event_id: @event.id }

      assert_select "form", action: convention_setup_event_event_choices_path(@event), method: "post" do
        assert_select "input#event_choice_label", name: "event_choice[label]"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested event_choice form" do
      event_choice = FactoryGirl.create(:event_choice)
      get :edit, params: { id: event_choice.to_param }

      assert_select "h1", "Editing Event Choice"
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventChoice" do
        expect do
          post :create, params: { event_id: @event.id, event_choice: valid_attributes }
        end.to change(EventChoice, :count).by(1)
      end

      it "redirects to the created event_choice" do
        post :create, params: { event_id: @event.id, event_choice: valid_attributes }
        expect(response).to redirect_to(convention_setup_event_event_choices_path(@event))
      end
    end

    describe "with invalid params" do
      it "does not create an event_choice" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventChoice).to receive(:valid?).and_return(false)
        expect do
          post :create, params: { event_id: @event.id, event_choice: {optional: false} }
        end.not_to change(EventChoice, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventChoice).to receive(:valid?).and_return(false)
        post :create, params: { event_id: @event.id, event_choice: {optional: false} }

        assert_select "h3", "New Event Choice"
      end
    end

    describe "with translations specified for label/tooltip" do
      before(:each) do
        @ec_params = {
          "cell_type" => "boolean",
          "multiple_values" => "",
          "translations_attributes" => {
            "1" => {
              "id" => "",
              "locale" => "en",
              "label" => "label_en",
              "tooltip" => "tool_en"
            }, "2" => {
              "id" => "",
              "locale" => "fr",
              "label" => "label_fr",
              "tooltip" => "tool_fr"}
          },
          "optional" => "0",
          "optional_if_event_choice_id" => ""
        }
      end

      it "can create the event_choice" do
        expect do
          post :create, params: { event_id: @event.id, event_choice: @ec_params, locale: "en" }
        end.to change(EventChoice, :count).by(1)
        ec = EventChoice.last
        I18n.locale = "en"
        expect(ec.label).to eq("label_en")
        expect(ec.tooltip).to eq("tool_en")
        I18n.locale = "fr"
        expect(ec.label).to eq("label_fr")
        expect(ec.tooltip).to eq("tool_fr")
        I18n.locale = "en"
      end
    end
  end

  describe "PUT update" do
    let(:event_choice) { EventChoice.create! valid_attributes.merge(event: @event) }

    describe "with valid params" do
      it "updates the requested event_choice" do
        expect do
          put :update, params: { id: event_choice.to_param, event_choice: valid_attributes.merge(label: "NeW Label") }
        end.to change { event_choice.reload.label }
      end

      it "redirects to the event's event_choices page" do
        put :update, params: { id: event_choice.to_param, event_choice: valid_attributes }
        expect(response).to redirect_to([:convention_setup, @event, :event_choices])
      end
    end

    describe "with invalid params" do
      it "does not update the event_choice" do
        event_choice # create base object before setting up expectation
        allow_any_instance_of(EventChoice).to receive(:valid?).and_return(false)
        expect do
          put :update, params: { id: event_choice.to_param, event_choice: valid_attributes.merge(label: "NeW Label") }
        end.not_to change { event_choice.reload.label }
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: event_choice.to_param, event_choice: {cell_type: "fake", optional: false} }
        assert_select "h1", "Editing Event Choice"
      end
    end
  end

  describe "PUT update_row_order" do
    let(:event) { FactoryGirl.create(:event) }
    let!(:event_choice_1) { FactoryGirl.create(:event_choice, event: event) }
    let!(:event_choice_2) { FactoryGirl.create(:event_choice, event: event) }

    it "updates the order" do
      put :update_row_order, params: { event_id: event.to_param, id: event_choice_1.to_param, row_order_position: 1 }
      expect(event_choice_2.reload.position).to eq(1)
      expect(event_choice_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_choice" do
      event_choice = FactoryGirl.create(:event_choice)
      expect do
        delete :destroy, params: { id: event_choice.to_param }
      end.to change(EventChoice, :count).by(-1)
    end

    it "redirects to the event_choices list" do
      event_choice = FactoryGirl.create(:event_choice)
      event = event_choice.event
      delete :destroy, params: { id: event_choice.to_param }
      expect(response).to redirect_to(convention_setup_event_event_choices_path(event))
    end
  end
end
