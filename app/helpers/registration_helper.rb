module RegistrationHelper
  def previous_registrants_for(user)
    options = []
    user.user_conventions.where.not(subdomain: Apartment::Tenant.current).order(created_at: :desc).each do |user_convention|
      subdomain = user_convention.subdomain
      Apartment::Tenant.switch(subdomain) do
        user.reload.registrants.active.each do |registrant|
          options << ["#{subdomain} - #{registrant}", RegistrantCopier.build_key(subdomain, registrant.id)]
        end
      end
    end

    options
  end
end
