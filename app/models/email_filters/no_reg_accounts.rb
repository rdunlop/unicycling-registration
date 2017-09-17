class EmailFilters::NoRegAccounts
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "no_reg_accounts"
  end

  def self.description
    "User Accounts with No Registrants"
  end

  def self.input_type
    :boolean
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
end
