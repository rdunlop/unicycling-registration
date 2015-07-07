class UsaMembershipsController < ApplicationController
  authorize_resource class: false
  before_action :load_family_registrants, only: :index
  before_action :load_registrants, only: [:index, :export]

  def index
    raise "Unable to access USA page on non-USA configuration" unless @config.usa_membership_config?
  end

  def update
    @registrant = Registrant.find(params[:registrant_id])
    cd = @registrant.contact_detail

    if params[:external_confirm]
      cd.update_attribute(:usa_confirmed_paid, true)
      flash[:notice] = "Marked #{@registrant} as confirmed"
    elsif params[:family_membership_registrant_id]
      cd.update_attribute(:usa_family_membership_holder_id, params[:family_membership_registrant_id])
      flash[:notice] = "Marked #{@registrant} as family-member"
    else
      flash[:alert] = "unknown action"
    end

    respond_to do |format|
      format.html { redirect_to usa_memberships_path }
      format.js do
        load_family_registrants
      end
    end
  end

  def export
    s = Spreadsheet::Workbook.new
    sheet = s.create_worksheet

    row = 0
    sheet[0, 0] = "ID"
    sheet[0, 1] = "USA#"
    sheet[0, 2] = "First Name"
    sheet[0, 3] = "Last Name"
    sheet[0, 4] = "Birthday"
    sheet[0, 5] = "Address Line1"
    sheet[0, 6] = "City"
    sheet[0, 7] = "State"
    sheet[0, 8] = "Zip"
    sheet[0, 9] = "Country"
    sheet[0, 10] = "Phone"
    sheet[0, 11] = "Email"
    sheet[0, 12] = "Club"
    sheet[0, 13] = "Paid Individual Membership"
    sheet[0, 14] = "Paid Family Membership"
    sheet[0, 15] = "Paid Family Membership Details"
    sheet[0, 16] = "Paid with Family membership ID#"
    sheet[0, 17] = "Confirmed already a USA member"

    row = 1
    @registrants.includes(payment_details: [:payment]).each do |reg|
      sheet[row, 0] = reg.bib_number
      sheet[row, 1] = reg.contact_detail.usa_member_number
      sheet[row, 2] = reg.first_name
      sheet[row, 3] = reg.last_name
      sheet[row, 4] = reg.birthday
      sheet[row, 5] = reg.contact_detail.address
      sheet[row, 6] = reg.contact_detail.city
      sheet[row, 7] = reg.contact_detail.state
      sheet[row, 8] = reg.contact_detail.zip
      sheet[row, 9] = reg.contact_detail.country_residence
      sheet[row, 10] = reg.contact_detail.phone
      sheet[row, 11] = reg.contact_detail.email
      sheet[row, 12] = reg.club
      sheet[row, 13] = reg.paid_individual_usa?
      sheet[row, 14] = reg.paid_family_usa?
      sheet[row, 15] = reg.paid_family_usa? ? reg.usa_family_membership_details : ""
      sheet[row, 16] = reg.contact_detail.usa_family_membership_holder.try(:bib_number)
      sheet[row, 17] = reg.contact_detail.usa_confirmed_paid
      row += 1
    end

    report = StringIO.new
    s.write report

    respond_to do |format|
      format.xls { send_data report.string, filename: "registrants_with_usa_membership_details.xls" }
    end
  end

  private

  def load_registrants
    @registrants = Registrant.where(registrant_type: ["competitor", "noncompetitor"]).includes(:contact_detail => [:usa_family_membership_holder]).active
  end

  def load_family_registrants
    family_item = @config.usa_family_expense_item
    if family_item.present?
      @family_registrants = family_item.payment_details.includes(:registrant).paid.map{|pd| pd.registrant}
    else
      @family_registrants = []
    end
  end
end
