# A callback method which lists the possible domains to be checked
# We will verify each of them before requesting a certificate from Let's Encrypt for all of them
ApartmentAcmeClient.domains_to_check = lambda do
  # always assume base domain URL is correct
  domains = [Rails.application.secrets.domain]

  Tenant.all.each do |tenant|
    domains << tenant.permanent_url
    tenant.tenant_aliases.each do |tenant_alias|
      domains << tenant_alias.website_alias
    end
  end

  domains
end

# The base domain, a domain which is always going to be accessible.
# because we need a common domain to be used on each request.
# if not defined, the first 'domain_to_check' which succeeds will be used
ApartmentAcmeClient.common_name = Rails.application.secrets.domain

# Directory where to store the challenge files, Must be accessible via the internet
ApartmentAcmeClient.public_folder = "/home/ec2-user/unicycling-registration/current/public"

# Directory where to store certificates locally
# must persist between deployments, so that nginx can reference it permanently
ApartmentAcmeClient.certificate_storage_folder = "/home/ec2-user/unicycling-registration/current/public/system"

# for s3 storage
ApartmentAcmeClient.aws_region = Rails.application.secrets.aws_region
ApartmentAcmeClient.aws_bucket = Rails.application.secrets.aws_bucket

# For use in the nginx configuration
ApartmentAcmeClient.socket_path = "/tmp/unicorn-unicycling-registration.socket"
ApartmentAcmeClient.nginx_config_path = "/etc/nginx/conf.d/registration.conf"

# All connections are https connections now
ApartmentAcmeClient.verify_over_https = true
