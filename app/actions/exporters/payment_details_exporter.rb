class Exporters::PaymentDetailsExporter
  attr_accessor :expense_item

  def initialize(expense_item)
    @expense_item = expense_item
  end

  def headers
    [
      "Expense Item",
      "Details: #{expense_item.details_label}",
      "ID",
      "First Name",
      "Last Name",
      "Age",
      "City",
      "State",
      "Country of Residence",
      "Country Representing",
      "Email",
      "Club",
      "Free with registration?"
    ]
  end

  def rows
    data = []
    expense_item.payment_details.includes(:payment).each do |payment_detail|
      next unless payment_detail.payment.completed
      data << add_element(payment_detail, "No")
    end
    expense_item.free_items_with_reg_paid.each do |registrant_expense_item|
      data << add_element(registrant_expense_item, "Yes")
    end

    data
  end

  private

  def add_element(element, free_with_reg)
    reg = element.registrant
    [
      element.expense_item.to_s,
      element.details,
      reg.bib_number,
      reg.first_name,
      reg.last_name,
      reg.age,
      reg.contact_detail.city,
      reg.contact_detail.state,
      reg.contact_detail.country_residence,
      reg.contact_detail.country_representing,
      reg.contact_detail.email,
      reg.club,
      free_with_reg
    ]
  end
end
