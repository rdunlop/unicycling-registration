desc "Register a LetsEncrypt Client, create an open SSL key on S3 bucket"
task create_crypto_client: :environment do
  Encryption.new.register_new_client
  puts "done."
end

desc "Authorize all domains and request new certificate"
task renew_and_update_certificate: :environment do
  crypto = Encryption.new
  all_domains = CertificateManager.new.accessible_domains(true)
  puts "All domains to be requested: #{all_domains}"
  domains = crypto.authorize_domains(all_domains)
  puts "authorized-domains list: #{domains}"
  crypto.request_certificate(common_name: Rails.application.secrets.domain, domains: domains)
  puts "done."
end
