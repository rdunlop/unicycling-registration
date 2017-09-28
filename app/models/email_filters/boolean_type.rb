class EmailFilters::BooleanType
  attr_reader :filter, :description
  attr_reader :input_type

  def initialize(filter:, description:)
    @filter = filter
    @description = description
    @input_type = :boolean
  end

  def usable_by?(user)
    Pundit.policy(user, user).contact_registrants?
  end

  # For use in the input builder
  # Should return an array [descriptive_string, element_id]
  def show_argument(element)
    [element, element.id]
  end
end
