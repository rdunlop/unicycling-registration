require "open3"

class CertificateManager
  # Update the certs.yml file in the server_config directory
  # with the list of domains which this server is serving
  def self.update_domains_file(basic_only = false)
    new.update_domains_file(basic_only)
  end

  def self.renew_certificate
    new.renew_certificate
  end

  def self.update_nginx
    new.update_nginx
  end

  def renew_certificate
    Rails.logger.info "Renewing Certificate"
    Notifications.certificate_renewal_command_status("Starting Certificate Renewal [#{Rails.env}]", "", "", true).deliver_later
    cmd = Rails.root.join("server_config", "renew_certs.rb")
    run_command("sudo ruby #{cmd} -u -p -c #{certs_path}")
    run_command("sudo ruby #{cmd} -r -c #{certs_path}")
    Rails.logger.info "DONE Renewing Certificate"
  end

  def update_nginx
    Rails.logger.info "Creating new nginx configuration"
    Notifications.certificate_renewal_command_status("Starting nginx config [#{Rails.env}]", "", "", true).deliver_later
    cmd = Rails.root.join("server_config", "renew_certs.rb")
    run_command("sudo ruby #{cmd} -n -c #{certs_path} -d #{Rails.application.secrets.domain}")
    run_command("sudo service nginx restart")
    Rails.logger.info "DONE setting up nginx"
  end

  # returns an array containing 2 lists:
  # successful domains
  # rejected domains (those which don't appear properly configured in DNS)
  def accessible_domains(basic_only)
    # always assume base domain URL is correct
    domains = [Rails.application.secrets.domain]

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
    [domains, rejected_domains]
  end

  def update_domains_file(basic_only)
    domains, rejected_domains = accessible_domains(basic_only)

    # puts "the domains are: #{domains}"
    # puts "the rejected domains are: #{rejected_domains}"
    Notifications.certificate_renewal_command_status(
      "Updating certs.yml file",
      "good domains: #{domains.join(' ')}",
      "rejected domains: #{rejected_domains.join(' ')}",
      write_domains_file(domains))
  end

  private

  # returns true if successful
  def write_domains_file(domains)
    File.write(certs_path, YAML.dump(domains: domains)) > 0
  end

  def run_command(command)
    Open3.popen3(command) do |_stdin, stdout, stderr, wait_thr|
      stdout_lines = stdout.read
      # puts "stdout is:" + stdout_lines

      # to watch the output as it runs:
      # while line = stdout.gets
      #   puts line
      # end

      stderr_lines = stderr.read
      # puts "stderr is:" + stderr_lines
      exit_status = wait_thr.value

      Notifications.certificate_renewal_command_status(command, stdout_lines, stderr_lines, exit_status.success?).deliver_later

      unless exit_status.success?
        abort "FAILED !!! #{command}"
      end
    end
  end

  def certs_path
    Rails.root.join("public", "system", "certs.yml")
  end
end
