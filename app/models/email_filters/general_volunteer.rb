class EmailFilters::GeneralVolunteer
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::BooleanType.new(
      filter: "general_volunteer",
      description: "All User Accounts who have selected General Volunteer"
    )
  end

  def detailed_description
    "Emails of users/registrants who have chosen to volunteer"
  end

  def filtered_user_emails
    users = registrants.map(&:user).uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    Registrant.not_deleted.active.where(volunteer: true)
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    nil
  end

  def valid?
    true
  end
end
