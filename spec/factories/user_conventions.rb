FactoryGirl.define do
  factory :user_convention do
    user
    subdomain { Tenant.first.subdomain }
  end
end
