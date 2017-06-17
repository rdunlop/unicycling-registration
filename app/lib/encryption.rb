require 'openssl'
require 'acme-client'

# Initially, the system is only accessible via subdomain.example.com
# But, as we add more Conventions, we want to be able to access those also,
# thus we will need:
# - a.subdomain.example.com
# - b.subdomain.example.com
# - c.subdomain.example.com
#
# Also, each convention may add an "alias" for their convention, like:
# - www.naucc.com
# - french-convention.unicycle.fr
#
# Steps to make this work:
# 1) When a new Convention is created, or a new alias is added, configure nginx
#    so that it responds to that domain request
#    `rake update_nginx_config` (writes a new nginx.conf and restarts nginx)
#
# 2) Register the new domain with letsencrypt
#    `rake renew_and_update_certificate`
#
# Manage the encryption of the website (https).
class Encryption
  ENCRYPTION_S3_NAME = 'server_encryption_client_private_key.der'.freeze

  # Largely based on https://github.com/unixcharles/acme-client documentation
  def register_new
    raise StandardError.new("Private key already exists") if private_key_from_s3.present?

    private_key = create_private_key

    # Initialize the client
    new_client = Acme::Client.new(
      private_key: private_key,
      endpoint: server_endpoint
    )

    # If the private key is not known to the server, we need to register it for the first time.
    registration = new_client.register(contact: "mailto:#{Rails.application.secrets.server_admin_email}")

    # You may need to agree to the terms of service (that's up the to the server to require it or not but boulder does by default)
    registration.agree_terms

    save_private_key(private_key)
  end

  def authorize_domains(domains)
    successful_domains = domains.select {|domain| authorize_domain(domain) }
    successful_domains
  end

  # authorizes a domain with letsencrypt server
  # returns true on success, false otherwise.
  #
  # from https://github.com/unixcharles/acme-client/tree/master#authorize-for-domain
  def authorize_domain(domain)
    authorization = client.authorize(domain: domain)

    # This example is using the http-01 challenge type. Other challenges are dns-01 or tls-sni-01.
    challenge = authorization.http01

    # The http-01 method will require you to respond to a HTTP request.

    # You can retrieve the challenge token
    challenge.token # => "some_token"

    # You can retrieve the expected path for the file.
    challenge.filename # => ".well-known/acme-challenge/:some_token"

    # You can generate the body of the expected response.
    challenge.file_content # => 'string token and JWK thumbprint'

    # You are not required to send a Content-Type. This method will return the right Content-Type should you decide to include one.
    challenge.content_type

    # Save the file. We'll create a public directory to serve it from, and inside it we'll create the challenge file.
    FileUtils.mkdir_p(Rails.root.join('public', File.dirname(challenge.filename)))

    # We'll write the content of the file
    full_challenge_filename = Rails.root.join('public', challenge.filename)
    File.write(full_challenge_filename, challenge.file_content)

    # Optionally save the challenge for use at another time (eg: by a background job processor)
    #  File.write('challenge', challenge.to_h.to_json)

    # The challenge file can be served with a Ruby webserver.
    # You can run a webserver in another console for that purpose. You may need to forward ports on your router.
    #
    # $ ruby -run -e httpd public -p 8080 --bind-address 0.0.0.0

    # Load a saved challenge. This is only required if you need to reuse a saved challenge as outlined above.
    #  challenge = client.challenge_from_hash(JSON.parse(File.read('challenge')))

    # Once you are ready to serve the confirmation request you can proceed.
    challenge.request_verification # => true

    success = false
    10.times do
      if challenge.verify_status == 'valid' # may be 'pending' initially
        success = true
        break
      end

      # Wait a bit for the server to make the request, or just blink. It should be fast.
      sleep(1)
    end
    File.delete(full_challenge_filename)

    success
  end

  # Create a Certificate for our new set of domain names
  # returns that certificate
  def request_certificate(common_name:, domains:)
    # We're going to need a certificate signing request. If not explicitly
    # specified, the first name listed becomes the common name.
    csr = Acme::Client::CertificateRequest.new(common_name: common_name, names: domains)

    # We can now request a certificate. You can pass anything that returns
    # a valid DER encoded CSR when calling to_der on it. For example an
    # OpenSSL::X509::Request should work too.
    certificate = client.new_certificate(csr) # => #<Acme::Client::Certificate ....>

    certificate
  end

  def client
    @client ||= Acme::Client.new(
      private_key: private_key_from_s3,
      endpoint: server_endpoint
    )
  end

  private

  # Returns a private key
  def private_key_from_s3
    return nil unless s3_object.exists?

    OpenSSL::PKey::RSA.new(s3_object.get.body.read)
  end

  # saves a private key to s3
  def save_private_key(private_key)
    s3_object.put(body: private_key.to_der)
  end

  def s3_object
    s3 = Aws::S3::Resource.new(region: Rails.application.secrets.aws_region)
    object = s3.bucket(Rails.application.secrets.aws_bucket).object(ENCRYPTION_S3_NAME)
    object
  end

  def create_private_key
    OpenSSL::PKey::RSA.new(4096)
  end

  def server_endpoint
    # We need an ACME server to talk to, see github.com/letsencrypt/boulder
    # WARNING: This endpoint is the production endpoint, which is rate limited and will produce valid certificates.
    # You should probably use the staging endpoint for all your experimentation:
    if Rails.env.production? || Rails.env.stage?
      'https://acme-v01.api.letsencrypt.org/'
    else
      'https://acme-staging.api.letsencrypt.org/'
    end
  end
end
