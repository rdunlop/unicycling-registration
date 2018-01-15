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

describe TenantsController do
  let(:user) { FactoryGirl.create(:super_admin_user) }

  before(:each) do
    sign_in user
  end

  describe "index" do
    before :each do
      get :index
    end

    it "loads page" do
      expect(response).to be_success
    end
  end

  describe "new" do
    it "loads page" do
      get :new
      expect(response).to be_success
    end
  end

  describe "#create" do
    let(:code) { "this_is_the_code" }
    it "creates a new tenant" do
      expect do
        post :create, params: { code: code, tenant: { subdomain: "new_tenant", description: "My Tenant", admin_upgrade_code: "Hi" } }
      end.to change(Tenant, :count).by(1)
    end
  end
end
