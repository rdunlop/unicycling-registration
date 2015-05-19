class ExportPaymentsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource class: false

  include ExcelOutputter

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

    filename = "#{@config.short_name} Payments #{Date.today}"

    output_spreadsheet(headers, data, filename)
  end

  # PUT /export_payments/payment_details
  def payment_details
    headers = ["Payment ID", "Expense Item ID", "Item Description", "Amount Paid", "Registrant ID"]
    data = []
    # Marco, we don't include the Free T-Shirts
    PaymentDetail.paid.includes(:registrant).each do |payment_detail|
      data << [
        payment_detail.payment_id,
        payment_detail.expense_item.id,
        payment_detail.expense_item.to_s,
        payment_detail.amount.to_s,
        payment_detail.registrant.bib_number
      ]
    end

    filename = "#{@config.short_name} PaymentDetails #{Date.today}"

    output_spreadsheet(headers, data, filename)
  end
end
