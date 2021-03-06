class Exporters::OrganizationMembershipsExporter
  def initialize(registrants)
    @registrants = registrants
  end

  def headers
    [
      "Id",
      "Manual Organization Membership#",
      "System Organization Membership#",
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
    @registrants.includes(:organization_membership, payment_details: [:payment]).each do |reg|
      row = [
        reg.bib_number,
        reg.organization_membership_manual_member_number,
        reg.organization_membership_system_member_number,
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
        reg.organization_membership_confirmed?
      ]
      data << row
    end
    data
  end
end
