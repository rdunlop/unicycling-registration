FactoryBot.define do
  factory :convention_series_member do
    convention_series # FactoryBot
    tenant # FactoryBot
  end
end

# == Schema Information
#
# Table name: public.convention_series_members
#
#  id                   :bigint(8)        not null, primary key
#  convention_series_id :integer          not null
#  tenant_id            :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  convention_series_member_ids_unique                      (tenant_id,convention_series_id) UNIQUE
#  index_convention_series_members_on_convention_series_id  (convention_series_id)
#  index_convention_series_members_on_tenant_id             (tenant_id)
#
