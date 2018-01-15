class TenantCreationJob < ApplicationJob
  def perform(tenant_id)
    tenant = Tenant.find(tenant_id)

    Apartment::Tenant.create(tenant.subdomain)
    Apartment::Tenant.switch(tenant.subdomain) do
      Rails.application.load_seed
      Notifications.new_convention_created(tenant.description, tenant.subdomain).deliver_later
      ApartmentAcmeClient::RenewalService.run! unless Rails.env.test?
    end
  end
end
