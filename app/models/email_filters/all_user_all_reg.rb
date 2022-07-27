class EmailFilters::AllUserAllReg
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::BooleanType.new(
      filter: "all_user_all_reg",
      description: "All Confirmed User Accounts, and All Registrants"
    )
  end

  def detailed_description
    self.class.config.description
  end

  def filtered_user_emails
    users = User.this_tenant.all_with_registrants.confirmed
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    Registrant.all.map(&:email).compact.uniq
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
