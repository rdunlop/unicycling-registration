# == Schema Information
#
# Table name: public.tenant_aliases
#
#  id             :integer          not null, primary key
#  tenant_id      :integer          not null
#  website_alias  :string(255)      not null
#  primary_domain :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  verified       :boolean          default(FALSE), not null
#

class TenantAliasesController < ConventionSetupController
  before_action :authenticate_user!, except: [:verify]
  before_action :load_tenant_alias, only: [:activate, :destroy]

  before_action :authorize_setup, except: [:verify]
  before_action :skip_authorization, only: [:verify]
  before_action :set_breadcrumbs

  def index
    @tenant_alias = @tenant.tenant_aliases.first || TenantAlias.new
  end

  def create
    @tenant_alias = @tenant.tenant_aliases.build(tenant_alias_params)
    # verify that the Alias is properly configured on the internet.
    @tenant_alias.verified = true
    if @tenant_alias.save
      flash[:notice] = "Created Alias"
      flash[:notice] += "Alias Verified"
      redirect_to tenant_aliases_path
    else
      flash[:alert] = "Unable to create Alias"
      render :index
    end
  end

  # A request is made to this endpoint to verify that the particular domain is
  # properly configured in the DNS settings
  #
  # Example Request:
  # http://mydomain.com/tenant_aliases/14/verify
  #
  # If there is a TenantAlias#14 with website_alias of mydomain.com, return TRUE
  # If not, returne FALSE
  def verify
    tenant_alias = TenantAlias.find_by(id: params[:id])
    if tenant_alias.present? && tenant_alias.website_alias == request.host
      render text: "TRUE"
    else
      render text: "FALSE"
    end
  end

  def activate
    @tenant_alias.update_attribute(:primary_domain, true)
    flash[:notice] = "Alias Activated"
    redirect_to tenant_aliases_path
  end

  def destroy
    @tenant_alias.destroy
    flash[:notice] = "Alias Deleted"
    redirect_to tenant_aliases_path
  end

  private

  def load_tenant_alias
    @tenant_alias = TenantAlias.find(params[:id])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Domain Setup", tenant_aliases_path
  end

  def tenant_alias_params
    params.require(:tenant_alias).permit(:website_alias)
  end
end
