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
      response.should redirect_to(convention_setup_event_configuration_url)
    end
  end

  describe "as a logged in user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot view configurations" do
      get :convention_setup
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
