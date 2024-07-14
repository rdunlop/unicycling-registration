# Acts as a common ancestor to all email filters
class EmailFilters::BaseEmailFilter
  include EmailFilterOptOut

  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def user_emails
    @user_emails ||= allowed_emails(filtered_user_emails)
  end

  def registrant_emails
    @registrant_emails ||= allowed_emails(filtered_registrant_emails)
  end
end
