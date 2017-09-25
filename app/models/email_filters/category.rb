class EmailFilters::Category
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "category"
  end

  def self.description
    "Users who are assigned to any competition in this category"
  end

  # Possible options :boolean, :select, :multi_select
  def self.input_type
    :select
  end

  # For use in the input builder
  # Each of these objects should have a policy which
  # responds to `:contact_registrants?`
  def self.possible_arguments
    ::Category.all
  end

  def self.allowed_arguments(user)
    possible_arguments.select{|el| Pundit.policy(user, el).contact_registrants? }
  end

  def self.usable_by?(user)
    allowed_arguments(user).any?
  end

  # For use in the input builder
  # Should return an array [descriptive_string, element_id]
  def self.show_argument(element)
    [element, element.id]
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
