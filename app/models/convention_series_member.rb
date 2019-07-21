# == Schema Information
#
# Table name: public.convention_series_members
#
#  id                   :bigint           not null, primary key
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

class ConventionSeriesMember < ApplicationRecord
  belongs_to :convention_series
  belongs_to :tenant

  validates :convention_series, :tenant, presence: true
  validates :tenant_id, uniqueness: { scope: :convention_series_id }
end
