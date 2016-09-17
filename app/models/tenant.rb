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
  validate :subdomain_has_no_spaces
  before_validation :trim_subdomain

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
    "https://#{raw_url}"
  end

  def permanent_url
    "#{subdomain}.#{Rails.application.secrets.domain}"
  end

  def self.find_by_first_subdomain(hostname)
    find_by(subdomain: hostname.split('.')[0])
  end

  private

  def trim_subdomain
    self.subdomain = subdomain.strip
  end

  def subdomain_has_no_spaces
    if subdomain.present? && subdomain.include?(" ")
      errors[:subdomain] << "Subdomain cannot have spaces"
    end
  end
end
