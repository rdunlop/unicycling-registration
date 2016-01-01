class CertificateManager
  # Update the certs.yml file in the server_config directory
  # with the list of domains which this server is serving
  def self.update_domains_file(basic_only = false)
    new.update_domains_file(basic_only)
  end

  def update_domains_file(basic_only)
    domains = []
    rejected_domains = []
    Tenant.all.each do |tenant|
      domains << tenant.permanent_url
      unless basic_only
        tenant.tenant_aliases.each do |tenant_alias|
          if tenant_alias.properly_configured?
            domains << tenant_alias.website_alias
          else
            rejected_domains << tenant_alias.website_alias
          end
        end
      end
    end

    # this should be an E-mail message, or, at minimum, Rails.logger?
    puts "the domains are: #{domains}"
    puts "the rejected domains are: #{rejected_domains}"

    write_domains_file(domains)
  end

  private

  def write_domains_file(domains)
    File.write(Rails.root.join("server_config", "certs.yml"), YAML.dump(domains: domains))
  end
end
