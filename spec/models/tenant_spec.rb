# == Schema Information
#
# Table name: public.tenants
#
#  id                 :integer          not null, primary key
#  subdomain          :string(255)
#  description        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  admin_upgrade_code :string(255)
#

require 'spec_helper'

describe Tenant do
  let!(:tenant) { FactoryGirl.create(:tenant, subdomain: "robin") }

  context "with tenant aliases" do
    let!(:alias1) { FactoryGirl.create(:tenant_alias, website_alias: "reg.robinsite.com", tenant: tenant) }
    let!(:alias2) { FactoryGirl.create(:tenant_alias, website_alias: "reg.nationals.com", tenant: tenant) }

    it "matches the alias" do
      expect(described_class.find_tenant_by_hostname("reg.robinsite.com")).to eq(tenant)
    end

    it "returns nil for no match" do
      expect(described_class.find_tenant_by_hostname("reg.elsewhere.com")).to be_nil
    end

    context "with a primary_domain alias" do
      let!(:alias3) { FactoryGirl.create(:tenant_alias, website_alias: "my.website.com", tenant: tenant, primary_domain: true) }

      it "uses the default_host_domain and subdomain for default mailer" do
        expect(tenant.base_url).to eq("http://my.website.com")
      end
    end

    it "uses the default_host_domain and subdomain for default mailer" do
      expect(tenant.base_url).to eq("http://robin.localhost.dev")
    end
  end

  context "ensure valid subdomain" do
    it "trims trailing spaces" do
      tenant = FactoryGirl.build(:tenant, subdomain: "testing ")
      tenant.save
      expect(tenant.subdomain).to eq("testing")
    end

    it "trims leading spaces" do
      tenant = FactoryGirl.build(:tenant, subdomain: " testing")
      tenant.save
      expect(tenant.subdomain).to eq("testing")
    end

    it "doesn't allow subdomain with spaces" do
      tenant = FactoryGirl.build(:tenant, subdomain: "not allowed")
      expect(tenant).not_to be_valid
    end
  end

  context "without tenant aliases" do
    it "matches based on the subdomain" do
      expect(described_class.find_tenant_by_hostname("robin.localhost.dev")).to eq(tenant)
    end
  end
end
