module SubdomainHelper
  def url_for(options = nil)
    if options.is_a?(Hash) && !Rails.env.test?
      current_tenant = Apartment::Tenant.current
      tenant = Tenant.find_by(subdomain: current_tenant)
      raise Errors::TenantNotFound unless tenant
      options[:host] = tenant.base_url
    end
    super
  end
end
