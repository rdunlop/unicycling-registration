class EmailFilters::Event
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "event"
  end

  def self.description
    "Users who have SIGNED UP for an Event"
  end

  # Possible options :boolean, :select, :multi_select
  def self.input_type
    :select
  end

  # For use in the input builder
  # Each of these objects should have a policy which
  # responds to `:contact_registrants?`
  def self.possible_arguments
    ::Event.all
  end

  # For use in the input builder
  # Should return an array [descriptive_string, element_id]
  def self.show_argument(element)
    ["#{element.category} - #{element}", element.id]
  end

  def detailed_description
    "Emails of users/registrants Signed up for the Event: #{event}"
  end

  def filtered_user_emails
    users = event.registrant_event_sign_ups.signed_up.map(&:registrant).map(&:user).uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    []
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
