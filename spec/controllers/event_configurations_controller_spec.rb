require 'spec_helper'

describe EventConfigurationsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # EventConfiguration. As you add validations to EventConfiguration, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      standard_skill_closed_date: Date.tomorrow,
      :translations_attributes => {
        "1" => {
          locale: "en",
          short_name: "something short",
          long_name: "Something Long"
        }
      },
      style_name: "unicon_17"
    }
  end

  describe "GET index" do
    it "assigns all event_configurations as @event_configurations" do
      event_configuration = EventConfiguration.create! valid_attributes
      get :index, {}
      assigns(:event_configurations).should eq([event_configuration])
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventConfiguration" do
        expect {
          post :create, {:event_configuration => valid_attributes}
        }.to change(EventConfiguration, :count).by(1)
      end

      it "assigns a newly created event_configuration as @event_configuration" do
        post :create, {:event_configuration => valid_attributes}
        assigns(:event_configuration).should be_a(EventConfiguration)
        assigns(:event_configuration).should be_persisted
      end

      it "redirects to the created event_configuration" do
        post :create, {:event_configuration => valid_attributes}
        response.should redirect_to(event_configurations_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_configuration as @event_configuration" do
        # Trigger the behavior that occurs when invalid params are submitted
        EventConfiguration.any_instance.stub(:save).and_return(false)
        post :create, {:event_configuration => {:long_name => "long name"}}
        assigns(:event_configuration).should be_a_new(EventConfiguration)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        EventConfiguration.any_instance.stub(:save).and_return(false)
        post :create, {:event_configuration => {:long_name => "long name"}}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event_configuration" do
        event_configuration = EventConfiguration.create! valid_attributes
        # Assuming there are no other event_configurations in the database, this
        # specifies that the EventConfiguration created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        EventConfiguration.any_instance.should_receive(:update_attributes).with({})
        put :update, {:id => event_configuration.to_param, :event_configuration => {'these' => 'params'}}
      end

      it "assigns the requested event_configuration as @event_configuration" do
        event_configuration = EventConfiguration.create! valid_attributes
        put :update, {:id => event_configuration.to_param, :event_configuration => valid_attributes}
        assigns(:event_configuration).should eq(event_configuration)
      end

      it "redirects to the event_configuration" do
        event_configuration = EventConfiguration.create! valid_attributes
        put :update, {:id => event_configuration.to_param, :event_configuration => valid_attributes}
        response.should redirect_to(event_configurations_path)
      end
    end

    describe "with invalid params" do
      it "assigns the event_configuration as @event_configuration" do
        event_configuration = EventConfiguration.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        EventConfiguration.any_instance.stub(:save).and_return(false)
        put :update, {:id => event_configuration.to_param, :event_configuration => {:long_name => "long name"}}
        assigns(:event_configuration).should eq(event_configuration)
      end

      it "re-renders the 'edit' template" do
        event_configuration = EventConfiguration.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        EventConfiguration.any_instance.stub(:save).and_return(false)
        put :update, {:id => event_configuration.to_param, :event_configuration => {:long_name => "long name"}}
        response.should render_template("index")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_configuration" do
      event_configuration = EventConfiguration.create! valid_attributes
      expect {
        delete :destroy, {:id => event_configuration.to_param}
      }.to change(EventConfiguration, :count).by(-1)
    end

    it "redirects to the event_configurations list" do
      event_configuration = EventConfiguration.create! valid_attributes
      delete :destroy, {:id => event_configuration.to_param}
      response.should redirect_to(event_configurations_url)
    end
  end

  describe "as a logged in user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot view configurations" do
      get :index
      response.should redirect_to(root_path)
    end
    it "Cannot edit configuration" do
      event_configuration = EventConfiguration.create! valid_attributes
      get :base_settings, {:id => event_configuration.to_param}
      response.should redirect_to(root_path)
    end

    describe "POST 'test_mode_role'" do
      before :each do
        request.env["HTTP_REFERER"] = root_url
      end
      it "redirects to root" do
        post 'test_mode_role', role: "normal_user"
        response.should redirect_to(root_path)
      end
      it "changes my user to admin" do
        post 'test_mode_role', :role => "admin"
        @user.reload
        @user.has_role?(:admin).should == true
      end
      it "cannot change if config test_mode is disabled" do
        FactoryGirl.create(:event_configuration, :test_mode => false)
        post 'test_mode_role', role: "admin"
        @user.reload
        @user.has_role?(:admin).should == false
      end
    end
  end
end
