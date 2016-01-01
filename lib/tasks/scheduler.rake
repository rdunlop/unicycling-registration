desc "This task is called by the Heroku scheduler add-on"
task update_registration_period: :environment do
  puts "Updating RegistrationPeriod:current_period ..."
  RegistrationPeriod.update_registration_periods
  puts "done."
end

desc "Update the SSL Certificates"
task update_domain_certs: :environment do
  cmd = Rails.root.join("server_config", "renew_certs.rb")
  puts "Updating list of domains"
  CertificateManager.update_domains_file
  puts "Updating SSL Certificates"
  `#{cmd} -u`
  `#{cmd} -r`
  # puts "Updating nginx configuration to use the new SSL Certificate"
  # `#{cmd} -n`
  # puts "Restarting nginx"
  # `#{cmd} -d`
  puts "done."
end

desc "Create Initial Ngnix Configuration (without SSL)"
task create_base_nginx_configuration: :environment do
  puts "updating certs.yml file"
  CertificateManager.update_domains_file(true)
  puts "Updating Ngnix Configuration"
  cmd = Rails.root.join("server_config", "renew_certs.rb")
  `#{cmd} -n --no-ssl`
  puts "done."
end
