FactoryBot.define do
  factory :tenant_alias do
    website_alias "test.site.com"
    primary_domain false
    tenant # FactoryBot
  end
end

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
# Indexes
#
#  index_tenant_aliases_on_tenant_id_and_primary_domain  (tenant_id,primary_domain)
#  index_tenant_aliases_on_website_alias                 (website_alias)
#
