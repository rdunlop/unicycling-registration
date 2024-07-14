class EmailFilters::ExpenseItem < EmailFilters::BaseEmailFilter
  def self.config
    EmailFilters::SelectType.new(
      filter: "expense_item",
      description: "Users+Registrants who have PAID for a particular Expense Item",
      possible_arguments: ::ExpenseItem.all,
      custom_show_argument: proc { |element| [element.to_s, element.id] }
    )
  end

  def detailed_description
    "Emails of users/registrants who have Paid for #{expense_item}"
  end

  def filtered_user_emails
    users = registrants.map(&:user).uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    expense_item.paid_items.includes(registrant: %i[contact_detail user]).map(&:registrant)
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
