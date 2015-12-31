class CertificateManager
  # Update the certs.yml file in the server_config directory
  # with the list of domains which this server is serving
  def self.update_domains_file
    new.update_domains_file
  end

  def update_domains_file
    domains = []
    rejected_domains = []
    Tenant.all.each do |tenant|
      domains << tenant.permanent_url
      tenant.tenant_aliases.each do |tenant_alias|
        if tenant_alias.properly_configured?
          domains << tenant_alias.website_alias
        else
          rejected_domains << tenant_alias.website_alias
        end
      end
    end

    puts "the domains are: #{domains}"
    puts "the rejected domains are: #{rejected_domains}"

    write_domains_file(domains)
  end

  private

  def write_domains_file(domains)
    File.write(Rails.root.join("server_config", "certs.yml"), YAML.dump(domains: domains))
  end
end
