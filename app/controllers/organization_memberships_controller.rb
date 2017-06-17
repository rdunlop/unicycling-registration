class OrganizationMembershipsController < ApplicationController
  include ExcelOutputter
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :load_registrants, only: %i[index export]

  def index; end

  def toggle_confirm
    @registrant = Registrant.find(params[:id])
    cd = @registrant.contact_detail

    if cd.organization_membership_manually_confirmed?
      cd.update_attribute(:organization_membership_manually_confirmed, false)
      flash[:notice] = "Marked #{@registrant} as unconfirmed"
    else
      cd.update_attribute(:organization_membership_manually_confirmed, true)
      flash[:notice] = "Marked #{@registrant} as confirmed"
    end

    respond_to do |format|
      format.html { redirect_to organization_memberships_path }
      format.js do
        render "update"
      end
    end
  end

  def update_number
    @registrant = Registrant.find(params[:id])
    cd = @registrant.contact_detail

    if params[:membership_number]
      cd.update_attribute(:organization_member_number, params[:membership_number])
      flash[:notice] = "Updated Member Number"
    else
      flash[:alert] = "Unable to update member number"
    end

    respond_to do |format|
      format.js do
        render "update"
      end
    end
  end

  def export
    exporter = Exporters::OrganizationMembershipsExporter.new(@registrants)
    output_spreadsheet(exporter.headers, exporter.rows, "registrants_with_membership_details")
  end

  private

  def authorize_admin
    authorize current_user, :manage_memberships?
  end

  def load_registrants
    @registrants = Registrant.where(registrant_type: ["competitor", "noncompetitor"]).includes(:contact_detail).active
  end
end
