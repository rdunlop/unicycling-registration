FactoryBot.define do
  factory :user_convention do
    user
    subdomain { Tenant.first.subdomain }
  end
end

# == Schema Information
#
# Table name: public.user_conventions
#
#  id                        :integer          not null, primary key
#  user_id                   :integer          not null
#  legacy_user_id            :integer
#  subdomain                 :string           not null
#  legacy_encrypted_password :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
