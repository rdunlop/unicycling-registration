class EmailFilters::SignedUpCategory
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "signed_up_category",
      description: "Users who have SIGNED UP to any event in this category",
      possible_arguments: ::Category.all
    )
  end

  def detailed_description
    "Emails of users/registrants Signed up for any event in #{signed_up_category}"
  end

  def filtered_user_emails
    users = signed_up_category.events.map do |event|
      event.registrant_event_sign_ups.signed_up.map(&:registrant).map(&:user).uniq
    end.flatten.uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    []
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    signed_up_category
  end

  def valid?
    signed_up_category
  end

  private

  def signed_up_category
    ::Category.find(arguments) if arguments.present?
  end
end
