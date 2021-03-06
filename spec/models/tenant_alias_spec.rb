# == Schema Information
#
# Table name: public.tenant_aliases
#
#  id             :integer          not null, primary key
#  tenant_id      :integer          not null
#  website_alias  :string           not null
#  primary_domain :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  verified       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_tenant_aliases_on_tenant_id_and_primary_domain  (tenant_id,primary_domain)
#  index_tenant_aliases_on_website_alias                 (website_alias)
#

require 'spec_helper'

describe TenantAlias do
  let(:tenant) { FactoryBot.create(:tenant, subdomain: "robin") }

  before do
    FactoryBot.create(:tenant_alias, website_alias: "reg.robinsite.com", tenant: tenant, primary_domain: true)
  end

  it "cannot have multiple primary_domains" do
    alias2 = FactoryBot.build(:tenant_alias, website_alias: "reg.nationals.com", tenant: tenant, primary_domain: true)

    expect(alias2).to be_invalid
  end

  it "can have multiple non-primary domains" do
    alias2 = FactoryBot.build(:tenant_alias, website_alias: "reg.nationals.com", tenant: tenant, primary_domain: false)

    expect(alias2).to be_valid
    alias2.save!

    alias3 = FactoryBot.build(:tenant_alias, website_alias: "reg.unicon.com", tenant: tenant, primary_domain: false)

    expect(alias3).to be_valid
    alias3.save!
  end
end
