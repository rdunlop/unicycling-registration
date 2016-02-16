class OrganizationMembershipsController < ApplicationController
  include ExcelOutputter
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :load_registrants, only: [:index, :export]

  def index
  end

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
    headers = [
      "ID",
      "Organization Membership#",
      "First Name",
      "Last Name",
      "Birthday",
      "Address Line1",
      "City",
      "State",
      "Zip",
      "Country",
      "Phone",
      "Email",
      "Club",
      "Confirmed already a member"
    ]

    data = []
    @registrants.includes(payment_details: [:payment]).each do |reg|
      row = [
        reg.bib_number,
        reg.contact_detail.organization_member_number,
        reg.first_name,
        reg.last_name,
        reg.birthday,
        reg.contact_detail.address,
        reg.contact_detail.city,
        reg.contact_detail.state,
        reg.contact_detail.zip,
        reg.contact_detail.country_residence,
        reg.contact_detail.phone,
        reg.contact_detail.email,
        reg.club,
        reg.contact_detail.organization_membership_confirmed?
      ]
      data << row
    end
    @headers = headers
    @rows = data

    output_spreadsheet(headers, data, "registrants_with_membership_details")
  end

  private

  def authorize_admin
    authorize current_user, :manage_memberships?
  end

  def load_registrants
    @registrants = Registrant.where(registrant_type: ["competitor", "noncompetitor"]).includes(:contact_detail).active
  end
end
