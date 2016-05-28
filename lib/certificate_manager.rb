require "open3"

class CertificateManager
  def self.update_nginx
    new.update_nginx
  end

  def update_nginx
    Rails.logger.info "Creating new nginx configuration"
    Notifications.certificate_renewal_command_status("Starting nginx config [#{Rails.env}]", "", "", true).deliver_later
    cmd = Rails.root.join("server_config", "renew_certs.rb")
    with_ssl = cert_exists? ? "" : "--no-ssl"
    run_command("sudo ruby #{cmd} -n #{with_ssl} -d #{Rails.application.secrets.domain}")
    restart_nginx
    Rails.logger.info "DONE setting up nginx"
  end

  def restart_nginx
    run_command("sudo service nginx restart")
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

  def store_certificate(certificate)
    # Save the certificate and the private key to files
    File.write(cert_path("privkey.pem"), certificate.request.private_key.to_pem)
    File.write(cert_path("cert.pem"), certificate.to_pem)
    File.write(cert_path("chain.pem"), certificate.chain_to_pem)
    File.write(cert_path("fullchain.pem"), certificate.fullchain_to_pem)

    store_s3_file("privkey.pem", certificate.request.private_key.to_pem)
    store_s3_file("cert.pem", certificate.to_pem)
    store_s3_file("chain.pem", certificate.chain_to_pem)
    store_s3_file("fullchain.pem", certificate.fullchain_to_pem)
  end

  # do we have a certificate on this server?
  # We cannot start nginx when it is pointing at a non-existing certificate,
  # so we need to check
  def cert_exists?
    File.exist?(cert_path("privkey.pem"))
  end

  private

  def store_s3_file(filename, file_contents)
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets.aws_region)
    object = s3.bucket(Rails.application.secrets.aws_bucket).object(filename)
    object.put(body: file_contents)
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

  def cert_path(filename)
    Rails.root.join("public", "system", filename)
  end
end
