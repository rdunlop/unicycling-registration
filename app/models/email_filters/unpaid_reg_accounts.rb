class EmailFilters::UnpaidRegAccounts
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "unpaid_reg_accounts"
  end

  def self.description
    "User Accounts with ANY Registrants who have NOT Paid Reg Fees"
  end

  def self.input_type
    :boolean
  end

  # Not necessary
  def self.possible_arguments
    nil
  end

  def self.usable_by?(user)
    Pundit.policy(user, user).contact_registrants?
  end

  # Not necessary
  def self.show_argument(_element)
    nil
  end

  def detailed_description
    self.class.description
  end

  def filtered_user_emails
    users = User.this_tenant.unpaid_reg_fees
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
