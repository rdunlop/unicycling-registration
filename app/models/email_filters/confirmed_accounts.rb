class EmailFilters::ConfirmedAccounts
  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "confirmed_accounts"
  end

  def self.description
    "Confirmed User Accounts"
  end

  def self.input_type
    :checkbox
  end

  # Not necessary
  def self.possible_arguments
    nil
  end

  # Not necessary
  def self.show_argument(_element)
    nil
  end

  def detailed_description
    self.class.description
  end

  def filtered_user_emails
    User.this_tenant.confirmed
  end

  def filtered_registrant_emails
    []
  end

  # object whose policy must respond to `:contact_registrants?`
  # or nil (which uses current_user)
  def authorization_object
    nil
  end
end
