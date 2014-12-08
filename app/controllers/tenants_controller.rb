class TenantsController < ApplicationController
  skip_authorization_check
  load_resource only: :create
  layout "global"

  def index
    @tenant = Tenant.new
  end

  def create
    if params[:code] == Rails.application.secrets.instance_creation_code
      if @tenant.save
        #Apartment::Tenant.create(@tenant.subdomain)
        #Apartment::Tenant.switch!(@tenant.subdomain)
        redirect_to root_url, notice: "New Convention created"
      else
        flash[:alert] = "Unable to create new convention"
        render :index
      end
    else
      flash[:alert] = "Incorrect creation code"
    end
  end

  private

  def tenant_params
    params.require(:tenant).permit(:subdomain, :description)
  end
end
