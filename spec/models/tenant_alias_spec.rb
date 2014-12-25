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
#

require 'spec_helper'

describe TenantAlias do
  let(:tenant) { FactoryGirl.create(:tenant, subdomain: "robin") }

  it "cannot have multiple primary_domains" do
    alias1 = FactoryGirl.create(:tenant_alias, website_alias: "reg.robinsite.com", tenant: tenant, primary_domain: true)
    alias2 = FactoryGirl.build(:tenant_alias, website_alias: "reg.nationals.com", tenant: tenant, primary_domain: true)

    expect(alias2).to be_invalid
  end

  it "can have multiple non-primary domains" do
    alias1 = FactoryGirl.create(:tenant_alias, website_alias: "reg.robinsite.com", tenant: tenant, primary_domain: true)
    alias2 = FactoryGirl.build(:tenant_alias, website_alias: "reg.nationals.com", tenant: tenant, primary_domain: false)

    expect(alias2).to be_valid
    alias2.save!

    alias3 = FactoryGirl.build(:tenant_alias, website_alias: "reg.unicon.com", tenant: tenant, primary_domain: false)

    expect(alias3).to be_valid
    alias3.save!
  end
end
