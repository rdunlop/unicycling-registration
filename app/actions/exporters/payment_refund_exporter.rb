# Each Registrant, and their amount owing, amount refunded
# For most registrants, this will be a single line, with only a payment
# for those with refunds, it will be a single line with both the payment and the refund
# for those with multiple payments, or multiple refunds, it will be multiple rows.
class Exporters::PaymentRefundExporter
  def headers
    ["Registrant ID", "Registrant Name", "Total Payment Received", "payment-date", "refund%", "refund amount", "refund date"]
  end

  def rows
    data = []
    Registrant.all.find_each do |registrant|
      reg_rows = registrant_rows(registrant)
      next if reg_rows.empty?

      data += reg_rows
    end

    data
  end

  private

  def registrant_rows(registrant)
    rows = []
    registrant.payments.each do |payment|
      rows << [
        registrant.bib_number,
        registrant.full_name,
        payment.payment_details.sum(&:amount),
        payment.payment_date.try(:iso8601),
        "?",
        amount_refunded(payment.payment_details),
        refund_date(payment.payment_details)
      ]
    end

    rows
  end

  def amount_refunded(payment_details)
    payment_details.refunded.sum(&:amount_refunded)
  end

  def refund_date(payment_details)
    refunds = payment_details.refunded.map(&:refund_detail).map(&:refund).uniq
    return if refunds.none?

    if refunds.count.positive?
      refunds.map(&:refund_date).map(&:iso8601).join(", ")
    else
      refunds.first.refund_date.try(:iso8601)
    end
  end
end
