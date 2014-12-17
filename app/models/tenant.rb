# == Schema Information
#
# Table name: public.tenants
#
#  id                 :integer          not null, primary key
#  subdomain          :string(255)
#  description        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  admin_upgrade_code :string(255)
#

class Tenant < ActiveRecord::Base
  validates :subdomain, :description, :admin_upgrade_code, presence: true
  validates :subdomain, uniqueness: true

  def to_s
    description
  end

  def url
    # XXX to be updated
    "#{subdomain}.localhost.dev:9292"
  end
end
