desc "This task is called by the Heroku scheduler add-on"
task update_registration_period: :environment do
  puts "Updating RegistrationPeriod:current_period ..."
  RegistrationCost.update_registration_periods
  puts "done."
end

desc "Update the nginx_configuration"
task update_nginx_config: :environment do
  puts "updating nginx configuration"
  CertificateManager.update_nginx
  puts "done."
end

desc "Create Initial Ngnix Configuration (without SSL)"
task create_base_nginx_configuration: :environment do
  puts "Updating Ngnix Configuration"
  cmd = Rails.root.join("server_config", "renew_certs.rb")
  `ruby #{cmd} -n --no-ssl`
  puts "done."
end
