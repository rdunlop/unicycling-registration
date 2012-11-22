ActionMailer::Base.smtp_settings = {  
    :address              => ENV['MAIL_SERVER'],
    :port                 => ENV['MAIL_PORT'],
    :domain               => ENV['MAIL_DOMAIN'],
    :user_name            => ENV['MAIL_USERNAME'],
    :password             => ENV['MAIL_PASSWORD'],
    :authentication       => "plain",
    :enable_starttls_auto => (ENV['MAIL_TLS'].nil? ? true : ENV['MAIL_TLS'] == 'true')
}  
ActionMailer::Base.default :from => ENV['MAIL_FULL_EMAIL']

ActionMailer::Base.default_url_options[:host] = ENV['DOMAIN']
