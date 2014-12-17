module SubdomainHelper
  def with_subdomain(subdomain)
    subdomain = (subdomain || "")
    subdomain += "." unless subdomain.empty?
    host = Rails.application.config.action_mailer.default_url_options[:host]
    [subdomain, host].join
  end

  def url_for(options = nil)
    if options.kind_of?(Hash) && !Rails.env.test?
      current_tenant = Apartment::Tenant.current
      options[:host] = with_subdomain(current_tenant)
    end
    super
  end
end
