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
      "Club"
    ]
  end

  def rows
    data = []
    expense_item.payment_details.includes(:payment).each do |payment_detail|
      next unless payment_detail.payment.completed
      reg = payment_detail.registrant
      data << [
        payment_detail.expense_item.to_s,
        payment_detail.details,
        reg.bib_number,
        reg.first_name,
        reg.last_name,
        reg.age,
        reg.contact_detail.city,
        reg.contact_detail.state,
        reg.contact_detail.country_residence,
        reg.contact_detail.country_representing,
        reg.contact_detail.email,
        reg.club
      ]
    end

    data
  end
end
