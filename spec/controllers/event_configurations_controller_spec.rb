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
      test_mode: true,
      standard_skill_closed_date: Date.tomorrow,
      translations_attributes: {
        "1" => {
          locale: "en",
          short_name: "something short",
          long_name: "Something Long"
        }
      },
      style_name: "unicon_17"
    }
  end

  describe "as a logged in user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    let!(:event_configuration) { EventConfiguration.create! valid_attributes }

    it "Cannot edit configuration" do
      get :advanced_settings, {id: event_configuration.to_param}
      expect(response).to redirect_to(root_path)
    end

    describe "POST 'test_mode_role'" do
      before :each do
        request.env["HTTP_REFERER"] = root_url
      end
      it "redirects to root" do
        post 'test_mode_role', role: "normal_user"
        expect(response).to redirect_to(root_path)
      end
      it "changes my user to admin" do
        post 'test_mode_role', role: "admin"
        @user.reload
        expect(@user.has_role?(:admin)).to eq(true)
      end
      it "cannot change if config test_mode is disabled" do
        event_configuration.update_attribute(:test_mode, false)
        post 'test_mode_role', role: "admin"
        @user.reload
        expect(@user.has_role?(:admin)).to eq(false)
      end
    end
  end
end
