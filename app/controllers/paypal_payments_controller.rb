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
            PaymentMailer.delay.ipn_received("Payment already completed. Invoice ID: " + paypal.order_number)
          else
            payment.complete(transaction_id: paypal.transaction_id, payment_date: paypal.payment_date)
            PaymentMailer.delay.payment_completed(payment.id)
            if payment.total_amount != paypal.payment_amount
              PaymentMailer.delay.ipn_received("Payment total #{payment.total_amount} not equal to the paypal amount #{paypal.payment_amount}")
            end
          end
        else
          PaymentMailer.delay.ipn_received("Unable to find Payment with Invoice ID " + paypal.order_number)
        end
      end
    end
    render :nothing => true
  end

  # PayPal return endpoint
  def success
  end
end
