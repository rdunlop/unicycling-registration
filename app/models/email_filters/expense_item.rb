class EmailFilters::ExpenseItem
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "expense_item"
  end

  def self.description
    "Users who have PAID for a particular Expense Item"
  end

  # Possible options :boolean, :select, :multi_select
  def self.input_type
    :select
  end

  # For use in the input builder
  # Each of these objects should have a policy which
  # responds to `:contact_registrants?`
  def self.possible_arguments
    ::ExpenseItem.all
  end

  # For use in the input builder
  # Should return an array [descriptive_string, element_id]
  def self.show_argument(element)
    [element.to_s, element.id]
  end

  def detailed_description
    "Emails of users/registrants who have Paid for #{expense_item}"
  end

  def filtered_user_emails
    users = expense_item.paid_items.map(&:registrant).map(&:user).uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    []
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    expense_item
  end

  def valid?
    expense_item
  end

  private

  def expense_item
    ::ExpenseItem.find(arguments) if arguments.present?
  end
end
