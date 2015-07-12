class TenantsController < ApplicationController
  skip_authorization
  load_resource only: :create
  layout "global"

  def index
    @new_tenant = Tenant.new
  end

  def create
    @new_tenant = Tenant.new(tenant_params)
    if params[:code] == Rails.application.secrets.instance_creation_code
      if @new_tenant.save
        Apartment::Tenant.create(@new_tenant.subdomain)
        Apartment::Tenant.switch!(@new_tenant.subdomain)
        Rails.application.load_seed
        redirect_to root_url, notice: "New Convention created"
      else
        flash[:alert] = "Unable to create new convention"
        render :index
      end
    else
      flash[:alert] = "Incorrect creation code"
      render :index
    end
  end

  private

  def tenant_params
    params.require(:tenant).permit(:subdomain, :description, :admin_upgrade_code)
  end
end
