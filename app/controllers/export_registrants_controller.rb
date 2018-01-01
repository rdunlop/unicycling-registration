class ExportRegistrantsController < ApplicationController
  before_action :authenticate_user!
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

  def download_summaries
    authorize current_user, :manage_all_payments?

    headers = [
      "Registrant ID",
      "Paid?",
      "First Name",
      "Last Name",
      "Gender",
      "Age",
      "Paid Items",
      "Total Paid",
      "PayPal Invoice ID ",
      "Payment Notes",
      "Events"
    ]

    data = []
    Registrant.active_or_incomplete.includes(
      payment_details: [:payment],
      signed_up_events: [:event],
      registrant_choices: :event_choice,
      registrant_best_times: [:event]
    ).each do |registrant|
      completed_payments = registrant.payment_details.map(&:payment).select(&:completed?)
      data << [
        registrant.bib_number,
        registrant.reg_paid?,
        registrant.first_name,
        registrant.last_name,
        registrant.gender,
        registrant.age,
        paid_items_summary(registrant),
        registrant.amount_paid,
        completed_payments.map(&:invoice_id).join("\n"),
        completed_payments.map(&:note).join("\n"),
        event_summary(registrant)
      ]
    end

    filename = "#{@config.short_name} Registration Summaries #{Date.today}"

    output_spreadsheet(headers, data, filename)
  end

  def download_with_payment_details
    authorize current_user, :download_payments?

    headers = [
      "ID",
      "Organization Membership #",
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
      "User Email"
    ]

    data = []
    Registrant.active.includes(:user, :contact_detail).each do |reg|
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
        reg.user.email
      ]

      reg.paid_details.each do |pd|
        row << pd.line_item.to_s
        row << pd.details
      end
      data << row
    end

    output_spreadsheet(headers, data, "registrants_with_payments")
  end

  private

  def paid_items_summary(registrant)
    registrant.paid_line_items.map(&:to_s).join("\n")
  end

  def event_summary(registrant)
    registrant.signed_up_events.map do |resu|
      registrant.describe_event(resu.event)
    end.join("\n")
  end
end
