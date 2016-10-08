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

  describe "#verify" do
    before do
      sign_out user
    end

    let!(:tenant_alias) { FactoryGirl.create(:tenant_alias) }

    it "returns False by default" do
      get :verify, params: { id: 99 }
      expect(response).to be_success
      expect(response.body).to eq("FALSE")
    end

    it "returns false if the request is from a different domain" do
      @request.host = "otherdomain.com"
      get :verify, params: { id: tenant_alias.id }

      expect(response).to be_success
      expect(response.body).to eq("FALSE")
    end

    it "returns true if the request in from the correct domain" do
      @request.host = tenant_alias.website_alias
      get :verify, params: { id: tenant_alias.id }

      expect(response).to be_success
      expect(response.body).to eq("TRUE")
    end
  end
end
