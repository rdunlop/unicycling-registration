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

class Tenant < ActiveRecord::Base
  validates :subdomain, :description, :admin_upgrade_code, presence: true
  validates :subdomain, uniqueness: true

  has_many :tenant_aliases, dependent: :destroy, inverse_of: :tenant

  accepts_nested_attributes_for :tenant_aliases, allow_destroy: true

  def self.find_tenant_by_hostname(hostname)
    TenantAlias.find_by(website_alias: hostname).try(:tenant) || find_by_first_subdomain(hostname)
  end

  def to_s
    description
  end

  def base_url
    raw_url = tenant_aliases.primary.first.try(:to_s) || permanent_url
    "http://#{raw_url}"
  end

  def permanent_url
    "#{subdomain}.#{Rails.application.secrets.domain}"
  end

  def self.find_by_first_subdomain(hostname)
    where(subdomain: hostname.split('.')[0]).first
  end
end
