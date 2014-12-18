# encoding: utf-8

class TenantUploader < CarrierWave::Uploader::Base
  def subdomain
    Apartment::Tenant.current
  end
end
