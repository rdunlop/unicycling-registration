require 'spec_helper'

describe EventChoicesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @event = FactoryGirl.create(:event)
  end

  # This should return the minimal set of attributes required to create a valid
  # EventChoice. As you add validations to EventChoice, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      export_name: "100m",
      cell_type: "boolean",
      autocomplete: false,
      optional: false,
      optional_if_event_choice_id: nil,
      required_if_event_choice_id: nil,
      "translations_attributes"=>{
        "1"=>{
          "id"=>"",
          "locale"=>"en",
          "label"=>"label_en",
          "tooltip"=>"tool_en"
        }, "2"=>{
          "id"=>"",
          "locale"=>"fr",
          "label"=>"label_fr",
          "tooltip"=>"tool_fr"}
      }
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read event_choices" do
      get :index, {:event_id => @event.id}
      response.should redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all event_choices as @event_choices" do
      event_choice = EventChoice.create! valid_attributes.merge({:event_id => @event.id})
      get :index, {:event_id => @event.id}
      assigns(:event_choices).should eq(@event.event_choices)
    end
    it "does not show event choices from other events" do
      event_choice = FactoryGirl.create(:event_choice)
      get :index, {:event_id => @event.id}
      assigns(:event_choices).should eq(@event.event_choices)
    end
    it "assigns a new event_choice" do
      event_choice = EventChoice.create! valid_attributes.merge({:event_id => @event.id})
      get :index, {:event_id => @event.id}
      assigns(:event_choice).should be_a_new(EventChoice)
    end
  end

  describe "GET show" do
    it "assigns the requested event_choice as @event_choice" do
      event_choice = EventChoice.create! valid_attributes
      get :show, {:id => event_choice.to_param}
      assigns(:event_choice).should eq(event_choice)
    end
  end

  describe "GET edit" do
    it "assigns the requested event_choice as @event_choice" do
      event_choice = FactoryGirl.create(:event_choice)
      get :edit, {:id => event_choice.to_param}
      assigns(:event_choice).should eq(event_choice)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventChoice" do
        expect {
          post :create, {:event_id => @event.id, :event_choice => valid_attributes}
        }.to change(EventChoice, :count).by(1)
      end

      it "assigns a newly created event_choice as @event_choice" do
        post :create, {:event_id => @event.id, :event_choice => valid_attributes}
        assigns(:event_choice).should be_a(EventChoice)
        assigns(:event_choice).should be_persisted
      end

      it "redirects to the created event_choice" do
        post :create, {:event_id => @event.id, :event_choice => valid_attributes}
        response.should redirect_to(event_event_choices_path(@event))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_choice as @event_choice" do
        # Trigger the behavior that occurs when invalid params are submitted
        EventChoice.any_instance.stub(:valid?).and_return(false)
        EventChoice.any_instance.stub(:errors).and_return("something")
        post :create, {:event_id => @event.id, :event_choice => {:optional => false}}
        assigns(:event_choice).should be_a_new(EventChoice)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        EventChoice.any_instance.stub(:valid?).and_return(false)
        EventChoice.any_instance.stub(:errors).and_return("something")
        post :create, {:event_id => @event.id, :event_choice => {:optional => false}}
        response.should render_template("index")
      end
      it "loads the event" do
        EventChoice.any_instance.stub(:valid?).and_return(false)
        EventChoice.any_instance.stub(:errors).and_return("something")
        post :create, {:event_id => @event.id, :event_choice => {:optional => false}}
        assigns(:event).should == @event
      end
    end

    describe "with translations specified for label/tooltip" do
      before(:each) do
        @ec_params = {
          :export_name => "new_ec",
          "cell_type"=>"boolean",
          "multiple_values"=>"",
          "translations_attributes"=>{
            "1"=>{
              "id"=>"",
              "locale"=>"en",
              "label"=>"label_en",
              "tooltip"=>"tool_en"
            }, "2"=>{
              "id"=>"",
              "locale"=>"fr",
              "label"=>"label_fr",
              "tooltip"=>"tool_fr"}
          },
          "position"=>"6",
          "optional"=>"0",
          "optional_if_event_choice_id"=>"",
          "autocomplete"=>"0"
        }
      end

      it "can create the event_choice" do
        expect {
          post :create, :event_id => @event.id, :event_choice => @ec_params, :locale => "en"
        }.to change(EventChoice, :count).by(1)
        ec = EventChoice.last
        I18n.locale = "en"
        ec.label.should == "label_en"
        ec.tooltip.should == "tool_en"
        I18n.locale = "fr"
        ec.label.should == "label_fr"
        ec.tooltip.should == "tool_fr"
        I18n.locale = "en"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event_choice" do
        event_choice = EventChoice.create! valid_attributes
        # Assuming there are no other event_choices in the database, this
        # specifies that the EventChoice created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        EventChoice.any_instance.should_receive(:update_attributes).with({})
        put :update, {:id => event_choice.to_param, :event_choice => {'these' => 'params'}}
      end

      it "assigns the requested event_choice as @event_choice" do
        event_choice = EventChoice.create! valid_attributes
        put :update, {:id => event_choice.to_param, :event_choice => valid_attributes}
        assigns(:event_choice).should eq(event_choice)
      end

      it "redirects to the event_choice" do
        event_choice = EventChoice.create! valid_attributes
        put :update, {:id => event_choice.to_param, :event_choice => valid_attributes}
        response.should redirect_to(event_choice)
      end
    end

    describe "with invalid params" do
      it "assigns the event_choice as @event_choice" do
        event_choice = EventChoice.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        EventChoice.any_instance.stub(:valid?).and_return(false)
        EventChoice.any_instance.stub(:errors).and_return("something")
        put :update, {:id => event_choice.to_param, :event_choice => {:optional => false}}
        assigns(:event_choice).should eq(event_choice)
      end

      it "re-renders the 'edit' template" do
        event_choice = EventChoice.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        EventChoice.any_instance.stub(:valid?).and_return(false)
        EventChoice.any_instance.stub(:errors).and_return("something")
        put :update, {:id => event_choice.to_param, :event_choice => {:optional => false}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_choice" do
      event_choice = FactoryGirl.create(:event_choice)
      expect {
        delete :destroy, {:id => event_choice.to_param}
      }.to change(EventChoice, :count).by(-1)
    end

    it "redirects to the event_choices list" do
      event_choice = FactoryGirl.create(:event_choice)
      event = event_choice.event
      delete :destroy, {:id => event_choice.to_param}
      response.should redirect_to(event_event_choices_path(event))
    end
  end

end
