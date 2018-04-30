FactoryBot.define do
  factory :tenant do
    subdomain "test"
    description "MyString"
    admin_upgrade_code "upgrade thyself"
  end
end

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
# Indexes
#
#  index_tenants_on_subdomain  (subdomain)
#
