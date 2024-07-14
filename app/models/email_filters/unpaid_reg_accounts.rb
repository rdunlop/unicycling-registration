class EmailFilters::UnpaidRegAccounts < EmailFilters::BaseEmailFilter
  def self.config
    EmailFilters::BooleanType.new(
      filter: "unpaid_reg_accounts",
      description: "User Accounts with ANY Registrants who have NOT Paid Reg Fees"
    )
  end

  def detailed_description
    self.class.config.description
  end

  def filtered_user_emails
    users = User.this_tenant.unpaid_reg_fees(include_pending: false)
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
