class EmailFilters::SelectType
  attr_reader :filter, :description, :possible_arguments, :custom_show_argument
  attr_reader :input_type

  def initialize(filter:, description:, possible_arguments:, input_type: :select, custom_show_argument: nil)
    @filter = filter
    @description = description
    @possible_arguments = possible_arguments
    @input_type = input_type
    @custom_show_argument = custom_show_argument
  end

  def allowed_arguments(user)
    possible_arguments.select{|el| Pundit.policy(user, el).contact_registrants? }
  end

  def usable_by?(user)
    allowed_arguments(user).any?
  end

  # For use in the input builder
  # Should return an array [descriptive_string, element_id]
  def show_argument(element)
    if custom_show_argument.present?
      custom_show_argument.call(element)
    else
      [element, element.id]
    end
  end
end
