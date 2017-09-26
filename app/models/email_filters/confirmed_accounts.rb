class EmailFilters::ConfirmedAccounts
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::BooleanType.new(
      filter: "confirmed_accounts",
      description: "All Confirmed User Accounts"
    )
  end

  def detailed_description
    "Confirmed User Accounts"
  end

  def filtered_user_emails
    users = User.this_tenant.confirmed
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
