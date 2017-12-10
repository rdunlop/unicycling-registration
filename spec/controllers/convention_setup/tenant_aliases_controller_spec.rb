# == Schema Information
#
# Table name: public.tenant_aliases
#
#  id             :integer          not null, primary key
#  tenant_id      :integer          not null
#  website_alias  :string(255)      not null
#  primary_domain :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  verified       :boolean          default(FALSE), not null
#

require 'spec_helper'

describe ConventionSetup::TenantAliasesController do
  let(:user) { FactoryGirl.create(:super_admin_user) }

  before(:each) do
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

    it "loads a blank tenant_alias form" do
      assert_select "form#new_tenant_alias", 1
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
