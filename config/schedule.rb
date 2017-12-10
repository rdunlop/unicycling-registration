every 1.day, at: '12am', roles: [:db] do
  rake "update_registration_period"
end

every 1.week, roles: [:db] do
  rake "encryption:renew_and_update_certificate"
end
