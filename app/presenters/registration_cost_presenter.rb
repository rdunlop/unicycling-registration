class RegistrationCostPresenter
  include ApplicationHelper

  attr_accessor :registration_cost

  def initialize(registration_cost)
    @registration_cost = registration_cost
  end

  def describe_entries
    registration_cost.registration_cost_entries.map do |entry|
      results = [print_formatted_currency(entry.expense_item.cost), entry.age_description]
      string = results.compact.join(" ")
      if block_given?
        yield(string)
      else
        string
      end
    end.join(", ")
  end
end
