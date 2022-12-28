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
    Registrant.active_or_incomplete.all.find_each do |registrant|
      reg_rows = registrant_rows(registrant)
      next if reg_rows.empty?

      data += reg_rows
    end

    data
  end

  private

  def registrant_rows(registrant)
    rows = []
    if registrant.payments.completed.none?
      return [[
        registrant.bib_number,
        registrant.full_name
      ]]
    end

    registrant.payments.completed.each do |payment|
      refunds = payment.payment_details.map(&:refund_detail).compact.map(&:refund).uniq

      if refunds.any?
        refunds.each do |refund|
          rows << [
            registrant.bib_number,
            registrant.full_name,
            payment.payment_details.sum(&:amount).to_s,
            payment.completed_date.try(:iso8601),

            refund.percentage,
            amount_refunded(refund),
            refund.refund_date.iso8601
          ]
        end
      else
        rows << [
          registrant.bib_number,
          registrant.full_name,
          payment.payment_details.sum(&:amount).to_s,
          payment.completed_date.try(:iso8601),

          0,
          0,
          nil
        ]
      end
    end

    rows
  end

  def amount_refunded(refund)
    refund.refund_details.map(&:amount_refunded).sum.to_s
  end
end
