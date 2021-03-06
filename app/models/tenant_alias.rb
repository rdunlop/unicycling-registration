# == Schema Information
#
# Table name: public.tenant_aliases
#
#  id             :integer          not null, primary key
#  tenant_id      :integer          not null
#  website_alias  :string           not null
#  primary_domain :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  verified       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_tenant_aliases_on_tenant_id_and_primary_domain  (tenant_id,primary_domain)
#  index_tenant_aliases_on_website_alias                 (website_alias)
#

class TenantAlias < ApplicationRecord
  validates :website_alias, :tenant, presence: true
  validates :website_alias, uniqueness: true
  validates :primary_domain, uniqueness: { scope: :tenant_id }, if: :primary_domain?

  belongs_to :tenant, inverse_of: :tenant_aliases

  def self.primary
    where(primary_domain: true)
  end

  # Determine whether this alias is properly configured
  # Causes makes a request to a remote server (which should be THIS server)
  # and determines whether the request was properly received
  def properly_configured?
    options = {
      open_timeout: 5,
      use_ssl: true, # all connections are forced SSL now
      verify_mode: OpenSSL::SSL::VERIFY_NONE # because we might not have a valid cert yet
    }
    Net::HTTP.start(website_alias, options) do |http|
      response = http.get("/tenant_aliases/#{id}/verify")

      return false unless response.is_a?(Net::HTTPSuccess)

      response.body == "TRUE"
    end
  rescue SocketError, Net::OpenTimeout, Errno::ECONNREFUSED
    # SocketError if the server name doesn't exist in DNS
    # OpenTimeout if no server responds
    # ECONNREFUSED if the server responds with "No"
    false
  end

  def to_s
    website_alias
  end
end
