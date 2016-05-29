desc "Register a LetsEncrypt Client, create an open SSL key on S3 bucket"
task create_crypto_client: :environment do
  Encryption.new.register_new
  puts "done."
end

desc "Authorize all domains and request new certificate"
task renew_and_update_certificate: :environment do
  crypto = Encryption.new
  good_domains, rejected_domains = CertificateManager.new.accessible_domains(false)
  puts "All domains to be requested: #{good_domains}, invalid domains: #{rejected_domains}"
  domains = crypto.authorize_domains(good_domains)
  puts "authorized-domains list: #{domains}"
  certificate = crypto.request_certificate(common_name: Rails.application.secrets.domain, domains: domains)
  CertificateManager.store_certificate(certificate)
  puts "Restarting nginx with new certificate"
  CertificateManager.restart_nginx
  puts "done."
end
