desc "This task is called by the Heroku scheduler add-on"
task :update_registration_period => :environment do
  puts "Updating RegistrationPeriod:current_period ..."
  RegistrationPeriod.update_current_period
  puts "done."
end
