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
      get :index, event_id: @event.id
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all event_choices as @event_choices" do
      EventChoice.create! valid_attributes.merge(event_id: @event.id)
      get :index, event_id: @event.id
      expect(assigns(:event_choices)).to eq(@event.event_choices)
    end

    it "does not show event choices from other events" do
      FactoryGirl.create(:event_choice)
      get :index, event_id: @event.id
      expect(assigns(:event_choices)).to eq(@event.event_choices)
    end

    it "assigns a new event_choice" do
      EventChoice.create! valid_attributes.merge(event_id: @event.id)
      get :index, event_id: @event.id
      expect(assigns(:event_choice)).to be_a_new(EventChoice)
    end
  end

  describe "GET edit" do
    it "assigns the requested event_choice as @event_choice" do
      event_choice = FactoryGirl.create(:event_choice)
      get :edit, id: event_choice.to_param
      expect(assigns(:event_choice)).to eq(event_choice)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventChoice" do
        expect do
          post :create, event_id: @event.id, event_choice: valid_attributes
        end.to change(EventChoice, :count).by(1)
      end

      it "assigns a newly created event_choice as @event_choice" do
        post :create, event_id: @event.id, event_choice: valid_attributes
        expect(assigns(:event_choice)).to be_a(EventChoice)
        expect(assigns(:event_choice)).to be_persisted
      end

      it "redirects to the created event_choice" do
        post :create, event_id: @event.id, event_choice: valid_attributes
        expect(response).to redirect_to(convention_setup_event_event_choices_path(@event))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_choice as @event_choice" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventChoice).to receive(:valid?).and_return(false)
        post :create, event_id: @event.id, event_choice: {optional: false}
        expect(assigns(:event_choice)).to be_a_new(EventChoice)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(EventChoice).to receive(:valid?).and_return(false)
        post :create, event_id: @event.id, event_choice: {optional: false}
        expect(response).to render_template("index")
      end
      it "loads the event" do
        allow_any_instance_of(EventChoice).to receive(:valid?).and_return(false)
        post :create, event_id: @event.id, event_choice: {optional: false}
        expect(assigns(:event)).to eq(@event)
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
          "optional_if_event_choice_id" => "",
        }
      end

      it "can create the event_choice" do
        expect do
          post :create, event_id: @event.id, event_choice: @ec_params, locale: "en"
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
        # Assuming there are no other event_choices in the database, this
        # specifies that the EventChoice created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(EventChoice).to receive(:update_attributes).with({})
        put :update, id: event_choice.to_param, event_choice: {'these' => 'params'}
      end

      it "assigns the requested event_choice as @event_choice" do
        put :update, id: event_choice.to_param, event_choice: valid_attributes
        expect(assigns(:event_choice)).to eq(event_choice)
      end

      it "redirects to the event's event_choices page" do
        put :update, id: event_choice.to_param, event_choice: valid_attributes
        expect(response).to redirect_to([:convention_setup, @event, :event_choices])
      end
    end

    describe "with invalid params" do
      it "assigns the event_choice as @event_choice" do
        put :update, id: event_choice.to_param, event_choice: {cell_type: "fake", optional: false}
        expect(assigns(:event_choice)).to eq(event_choice)
      end

      it "re-renders the 'edit' template" do
        put :update, id: event_choice.to_param, event_choice: {cell_type: "fake", optional: false}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_choice" do
      event_choice = FactoryGirl.create(:event_choice)
      expect do
        delete :destroy, id: event_choice.to_param
      end.to change(EventChoice, :count).by(-1)
    end

    it "redirects to the event_choices list" do
      event_choice = FactoryGirl.create(:event_choice)
      event = event_choice.event
      delete :destroy, id: event_choice.to_param
      expect(response).to redirect_to(convention_setup_event_event_choices_path(event))
    end
  end
end
