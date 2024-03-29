class ExportPaymentsController < ApplicationController
  include ExcelOutputter

  before_action :authenticate_user!
  before_action :authorize_payment_admin

  def list
    add_breadcrumb "Payments Management", summary_payments_path
    add_breadcrumb "Download Payments"
  end

  # PUT /export_payments/payments
  def payments
    payments = Payment.completed
    headers = ["Payment ID", "Date of Purchase", "Total", "Transaction ID", "PayPal Invoice ID", "Note"]
    data = []
    payments.includes(:payment_details).each do |payment|
      data << [
        payment.id,
        payment.completed_date.to_s,
        payment.total_amount.to_s,
        payment.transaction_id,
        payment.invoice_id,
        payment.note
      ]
    end

    filename = "#{@config.short_name} Payments #{Date.current}"

    output_spreadsheet(headers, data, filename)
  end

  # PUT /export_payments/payment_details
  def payment_details
    headers = ["Payment ID", "Expense Item ID", "Item Description", "Amount Paid", "Registrant ID"]
    data = []
    # Marco, we don't include the Free T-Shirts
    PaymentDetail.paid.where(refunded: false).includes(:registrant).each do |payment_detail|
      data << [
        payment_detail.payment_id,
        payment_detail.line_item.id,
        payment_detail.line_item.to_s,
        payment_detail.amount.to_s,
        payment_detail.registrant.bib_number
      ]
    end
    RegistrantExpenseItem.free.includes(:registrant).each do |rei|
      next unless rei.registrant.reg_paid?

      data << [
        "Free With Reg",
        rei.line_item.id,
        rei.line_item.to_s,
        "0",
        rei.registrant.bib_number
      ]
    end

    filename = "#{@config.short_name} PaymentDetails #{Date.current}"

    output_spreadsheet(headers, data, filename)
  end

  # Each Registrant, and their amount owing, amount refunded
  # For most registrants, this will be a single line, with only a payment
  # for those with refunds, it will be a single line with both the payment and the refund
  # for those with multiple payments, or multiple refunds, it will be multiple rows.
  # PUT /export_payments/payments_by_registrant
  def payments_by_registrant
    filename = "#{@config.short_name} PaymentRefunds #{Date.current}"

    exporter = Exporters::PaymentRefundExporter.new

    output_spreadsheet(exporter.headers, exporter.rows, filename)
  end

  private

  def authorize_payment_admin
    authorize current_user, :manage_all_payments?
  end
end
