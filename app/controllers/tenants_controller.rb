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

  def index; end

  def new
    @new_tenant = Tenant.new
  end

  def create
    @new_tenant = Tenant.new(tenant_params)
    if params[:code] == Rails.application.secrets.instance_creation_code
      if @new_tenant.save
        TenantCreationJob.perform_later(@new_tenant.id)

        redirect_to tenants_url, notice: "New Convention created. It may take a minute to finish creating it. Please be patient"
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
