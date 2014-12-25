module SubdomainHelper
  def url_for(options = nil)
    if options.kind_of?(Hash) && !Rails.env.test?
      current_tenant = Apartment::Tenant.current
      tenant = Tenant.find_by(subdomain: current_tenant)
      options[:host] = tenant.base_url
    end
    super
  end
end
