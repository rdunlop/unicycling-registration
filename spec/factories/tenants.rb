FactoryGirl.define do
  factory :tenant do
    subdomain "test"
    description "MyString"
    admin_upgrade_code "upgrade thyself"
  end
end
