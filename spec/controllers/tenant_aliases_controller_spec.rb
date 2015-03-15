require 'spec_helper'

describe TenantAliasesController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Category. As you add validations to Category, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "something"
    }
  end

  describe "index" do
    before :each do
      get :index
    end

    it "loads a blank tenant_alias" do
      expect(assigns(:tenant_alias)).not_to be_persisted
    end
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read aliases" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end
end
