class EmailFilters::NonConfirmedOrganizationMembers < EmailFilters::BaseEmailFilter
  def self.config
    EmailFilters::BooleanType.new(
      filter: "non_confirmed_organization_members",
      description: "User+Registrants Accounts with Registrants who are not Unicycling-Organization-Members"
    )
  end

  def detailed_description
    self.class.config.description
  end

  def filtered_user_emails
    users = registrants.map(&:user).compact.uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    Registrant.where(registrant_type: ["competitor", "noncompetitor"]).active_or_incomplete.includes(:contact_detail, :organization_membership, :user).reject(&:organization_membership_confirmed?)
  end

  # object whose policy must respond to `:contact_registrants?`
  # or nil (which uses current_user)
  def authorization_object
    nil
  end

  def valid?
    true
  end
end
