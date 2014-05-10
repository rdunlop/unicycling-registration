class PaymentCreator
  attr_accessor :payment

  def initialize(payment)
    @payment = payment
  end

  def add_registrant(registrant)
    registrant.owing_registrant_expense_items.each do |reg_item|
      next if reg_item.free

      payment.payment_details.build(
        registrant: registrant,
        amount: reg_item.total_cost,
        expense_item: reg_item.expense_item,
        details: reg_item.details,
        free: reg_item.free)
    end
  end
end
