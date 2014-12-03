class RequiredExpenseItemCreator
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  def create
    # add the registration_period expense_item
    unless registrant.reg_paid?
      registrant.build_registration_item(registration_item)
    end

    required_expense_items.each do |ei|
      registrant.build_registration_item(ei)
    end
  end

  def registration_item
    rp = RegistrationPeriod.relevant_period(Date.today)
    rp.expense_item_for(registrant.competitor) unless rp.nil?
  end

  # any items which have a required element, but only 1 element in the group (no choices allowed by the registrant)
  def required_expense_items
    egs = ExpenseGroup.for_competitor_type(@registrant.competitor)

    egs.select { |expense_group| expense_group.expense_items.count == 1 }
      .map{ |expense_group| expense_group.expense_items.first }
  end
end
