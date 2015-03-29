class PaypalPaymentsController < ApplicationController
  skip_authorization_check
  skip_before_filter :verify_authenticity_token

  # PayPal notification endpoint
  def notification
    paypal = PaypalConfirmer.new(params, request.raw_post)
    if paypal.valid?
      if paypal.correct_paypal_account? && paypal.completed?
        if Payment.exists?(invoice_id: paypal.order_number)
          payment = Payment.find_by(invoice_id: paypal.order_number)
          if payment.completed
            PaymentMailer.ipn_received("Payment already completed. Invoice ID: " + paypal.order_number).deliver_later
          else
            payment.complete(transaction_id: paypal.transaction_id, payment_date: paypal.payment_date)
            PaymentMailer.payment_completed(payment).deliver_later
            if payment.total_amount != paypal.payment_amount
              PaymentMailer.ipn_received("Payment total #{payment.total_amount} not equal to the paypal amount #{paypal.payment_amount}").deliver_later
            end
          end
        else
          PaymentMailer.ipn_received("Unable to find Payment with Invoice ID " + paypal.order_number).deliver_later
        end
      end
    end
    render :nothing => true
  end

  # PayPal return endpoint
  def success
  end
end
