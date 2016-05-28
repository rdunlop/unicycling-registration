every 1.day, at: '12am', roles: [:db] do
  rake "update_registration_period"
end

case @environment
when "production"
  every 1.month, roles: [:db] do
    rake "renew_and_update_certificate"
  end
when "stage"
  every 1.day, roles: [:db] do
    rake "renew_and_update_certificate"
  end
end
