class ExportRegistrantsController < ApplicationController
  include ExcelOutputter

  def download_all
    authorize current_user, :manage_all_payments?

    headers = ["Registrant ID", "First Name", "Last Name", "Gender", "Address", "City", "Zip", "Country",
               "Place of Birth", "Birthday", "Italian Fiscal Code", "Volunteer", "email", "Phone", "Mobile", "User Email"]

    data = []
    Registrant.active_or_incomplete.includes(:contact_detail).each do |registrant|
      data << [
        registrant.bib_number,
        registrant.first_name,
        registrant.last_name,
        registrant.gender,
        registrant.contact_detail.try(:address),
        registrant.contact_detail.try(:city),
        registrant.contact_detail.try(:zip),
        registrant.contact_detail.try(:country),
        registrant.contact_detail.try(:birthplace),
        registrant.birthday,
        registrant.contact_detail.try(:italian_fiscal_code),
        registrant.volunteer,
        registrant.contact_detail.try(:email),
        registrant.contact_detail.try(:phone),
        registrant.contact_detail.try(:mobile),
        registrant.user.try(:email)
      ]
    end

    filename = "#{@config.short_name} Registrants #{Date.today}"

    output_spreadsheet(headers, data, filename)
  end

  def download_with_payment_details
    authorize current_user, :download_payments?

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

    row = 1
    Registrant.active.includes(payment_details: [:payment]).each do |reg|
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
      column = 13
      reg.paid_details.each do |pd|
        sheet[row, column] = pd.expense_item.to_s
        column += 1
        sheet[row, column] = pd.details
        column += 1
      end
      row += 1
    end

    report = StringIO.new
    s.write report

    respond_to do |format|
      format.xls { send_data report.string, filename: "registrants_with_payments.xls" }
    end
  end
end
