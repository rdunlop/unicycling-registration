class EmailFilters::Country
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "country",
      description: "Users who have select that they are representing the given country",
      possible_arguments: ISO3166::Country.all,
      custom_show_argument: proc { |element| [element.to_s, element.alpha2] },
      custom_policy: proc { |user| Pundit.policy(user, User).contact_registrants? }
    )
  end

  def detailed_description
    "Representing Country #{selected_country}"
  end

  def filtered_user_emails
    users = registrants.map(&:user)
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).uniq
  end

  def registrants
    Registrant.includes(:contact_detail).select do |registrant|
      registrant.country == selected_country
    end
  end

  # object whose policy must respond to `:contact_registrants?`
  # or nil (which uses current_user)
  def authorization_object
    nil
  end

  def valid?
    true
  end

  private

  def selected_country
    ISO3166::Country[arguments].name if arguments.present?
  end
end
