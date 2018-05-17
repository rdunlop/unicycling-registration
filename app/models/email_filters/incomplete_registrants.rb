class EmailFilters::IncompleteRegistrants
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::BooleanType.new(
      filter: "incomplete_registrants",
      description: "User Accounts with ANY Registrants who are incomplete"
    )
  end

  def detailed_description
    self.class.config.description
  end

  def filtered_user_emails
    users = User.where(id: registrants.pluck(:user_id))
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    Registrant.not_deleted.where.not(status: "active").includes(:contact_detail, :user)
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
