module SubdomainHelper
  def default_url_options(options = {})
    current_tenant = Apartment::Tenant.current
    tenant = Tenant.find_by(subdomain: current_tenant)
    raise Errors::TenantNotFound unless tenant
    { host: tenant.base_url }
  end
end
