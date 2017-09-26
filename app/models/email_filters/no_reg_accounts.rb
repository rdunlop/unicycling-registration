class EmailFilters::NoRegAccounts
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::BooleanType.new(
      filter: "no_reg_accounts",
      description: "User Accounts with No Registrants"
    )
  end

  def detailed_description
    self.class.config.description
  end

  def filtered_user_emails
    users = (User.this_tenant.confirmed - User.this_tenant.all_with_registrants)
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    []
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
