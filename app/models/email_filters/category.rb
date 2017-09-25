class EmailFilters::Category
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "category",
      description: "Users who are assigned to any competition in this category",
      possible_arguments: ::Category.all
    )
  end

  def detailed_description
    "Emails of users/registrants associated with any competition in #{category}"
  end

  def filtered_user_emails
    users = category.events.map(&:competitor_registrants).flatten.map(&:user)
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    category.events.map(&:competitor_registrants).flatten.map(&:contact_detail).compact.map(&:email).compact.uniq
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    category
  end

  def valid?
    category
  end

  private

  def category
    ::Category.find(arguments) if arguments.present?
  end
end
