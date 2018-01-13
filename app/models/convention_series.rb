# == Schema Information
#
# Table name: public.convention_series
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_convention_series_on_name  (name) UNIQUE
#

class ConventionSeries < ApplicationRecord
  has_many :convention_series_members, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  def add(tenant_name)
    convention_series_members.create(tenant: find_tenant(tenant_name))
  end

  def remove(tenant_name)
    convention_series_members.find_by(tenant: find_tenant(tenant_name)).destroy
  end

  def subdomains
    convention_series_members.includes(:tenant).pluck(Tenant.arel_table[:subdomain])
  end

  private

  def find_tenant(tenant_name)
    Tenant.find_by(subdomain: tenant_name)
  end
end
