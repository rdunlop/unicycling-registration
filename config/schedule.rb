every 1.day, at: '12am', roles: [:db] do
  rake "update_registration_period"
end
