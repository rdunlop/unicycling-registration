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

class TenantsController < ApplicationController
  # so that we can display this list without the known subdomain
  skip_before_action :load_tenant
  before_action :skip_authorization
  layout "global"

  def index
  end

  def new
    @new_tenant = Tenant.new
  end

  def create
    @new_tenant = Tenant.new(tenant_params)
    if params[:code] == Rails.application.secrets.instance_creation_code
      if @new_tenant.save
        Apartment::Tenant.create(@new_tenant.subdomain)
        Apartment::Tenant.switch!(@new_tenant.subdomain)
        Rails.application.load_seed
        Notifications.new_convention_created(@new_tenant.description, @new_tenant.subdomain).deliver_later
        redirect_to root_url, notice: "New Convention created. You may need to change the URL in your browser now"
      else
        flash[:alert] = "Unable to create new convention"
        render :new
      end
    else
      flash[:alert] = "Incorrect creation code"
      render :new
    end
  end

  private

  def tenant_params
    params.require(:tenant).permit(:subdomain, :description, :admin_upgrade_code)
  end
end
