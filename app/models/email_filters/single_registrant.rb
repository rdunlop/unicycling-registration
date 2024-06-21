class EmailFilters::SingleRegistrant
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "registrants",
      description: "Single Registrant (mostly used for email testing)",
      possible_arguments: Registrant.active
    )
  end

  def detailed_description
    "Email to a single registrant (and their user)"
  end

  def filtered_user_emails
    [registrant.user.email]
  end

  def filtered_registrant_emails
    [registrant.email]
  end

  def registrant
    Registrant.find(arguments)
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    nil
  end

  def valid?
    true
  end
end
