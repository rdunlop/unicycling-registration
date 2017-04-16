class RegistrationCostPresenter
  include ApplicationHelper

  attr_accessor :registration_cost

  def initialize(registration_cost)
    @registration_cost = registration_cost
  end

  def describe_entries
    registration_cost.registration_cost_entries.map do |entry|
      results = [print_formatted_currency(entry.expense_item.cost), age_description(entry)]
      string = results.compact.join(" ")
      if block_given?
        yield(string)
      else
        string
      end
    end.join(", ")
  end

  private

  def age_description(entry)
    if entry.min_age.present? && entry.max_age.present?
      "(Ages #{entry.min_age}-#{entry.max_age})"
    elsif entry.min_age.present?
      "(Ages #{entry.min_age}+"
    elsif entry.max_age.present?
      "(Ages < #{entry.max_age}"
    end
  end
end
