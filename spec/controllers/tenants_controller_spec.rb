# == Schema Information
#
# Table name: public.tenants
#
#  id                 :integer          not null, primary key
#  subdomain          :string
#  description        :string
#  created_at         :datetime
#  updated_at         :datetime
#  admin_upgrade_code :string
#
# Indexes
#
#  index_tenants_on_subdomain  (subdomain)
#

require 'spec_helper'

describe TenantsController do
  let(:user) { FactoryBot.create(:super_admin_user) }

  before do
    sign_in user
  end

  describe "index" do
    before do
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
