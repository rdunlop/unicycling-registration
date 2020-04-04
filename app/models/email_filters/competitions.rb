class EmailFilters::Competitions
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "competition",
      description: "Users+Registrants who are assigned to a competition",
      possible_arguments: Competition.event_order.all,
      input_type: :multi_select
    )
  end

  def detailed_description
    "Emails of users/registrants associated with #{competitions.map(&:to_s).join(' ')}"
  end

  def filtered_user_emails
    registrants.map(&:user).map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    competitions.flat_map(&:registrants)
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    competitions
  end

  def valid?
    competitions&.any?
  end

  private

  def competitions
    return @competitions if @competitions

    @competitions = Competition.where(id: arguments) if arguments.present?

    @competitions
  end
end
