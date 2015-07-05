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

class TenantAlias < ActiveRecord::Base
  validates :website_alias, :tenant, presence: true
  validates :website_alias, uniqueness: true
  validates :primary_domain, uniqueness: { scope: :tenant_id }, if: :primary_domain?

  belongs_to :tenant, inverse_of: :tenant_aliases

  def self.primary
    where(primary_domain: true)
  end

  def to_s
    website_alias
  end
end
