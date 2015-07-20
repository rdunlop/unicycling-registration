FactoryGirl.define do
  factory :tenant_alias do
    website_alias "test.site.com"
    primary_domain false
    tenant # FactoryGirl
  end
end
