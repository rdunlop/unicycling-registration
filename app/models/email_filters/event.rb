class EmailFilters::Event
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "event",
      description: "Users+Registrants who have SIGNED UP for an Event",
      possible_arguments: ::Event.all,
      custom_show_argument: proc { |element| ["#{element.category} - #{element}", element.id] }
    )
  end

  def detailed_description
    "Emails of users/registrants Signed up for the Event: #{event}"
  end

  def filtered_user_emails
    users = registrants.map(&:user).uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    event.registrant_event_sign_ups.signed_up.includes(registrant: %i[contact_detail user]).map(&:registrant)
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    event
  end

  def valid?
    event
  end

  private

  def event
    ::Event.find(arguments) if arguments.present?
  end
end
