every 1.day, at: '12am', roles: [:db] do
  rake "update_registration_period"
end

case @environment
when "production"
  every 1.month, roles: [:db] do
    rake "update_ssl_certificate"
  end
when "stage"
  # every 1.week, roles: [:db] do
  #   rake "update_ssl_certificate"
  # end
end
