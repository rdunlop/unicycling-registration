class Exporters::OrganizationMembershipsExporter
  def initialize(registrants)
    @registrants = registrants
  end

  def headers
    [
      "Id",
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
  end

  def rows
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
    data
  end
end
