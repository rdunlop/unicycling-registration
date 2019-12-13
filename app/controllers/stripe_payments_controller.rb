class StripePaymentsController < ApplicationController
  before_action :skip_authorization
  skip_before_action :verify_authenticity_token

  # Stripe post-back endpoint
  def stripe
    process_notification
  end

  private

  def payment
    @payment ||= Payment.find(params[:id])
  end

  def process_notification
    Stripe.api_key = @config.stripe_secret_key

    # Token is created using Checkout or Elements!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]

    if payment.completed
      PaymentMailer.ipn_received("Stripe Payment already completed. Invoice ID: " + paypal.order_number).deliver_later
    else
      charge = create_charge(token)
      if charge.captured
        payment.complete(transaction_id: charge.id, payment_date: Time.current)
        PaymentMailer.payment_completed(payment).deliver_later
        redirect_to success_payments_path
        return
      else
        PaymentMailer.ipn_received("Unable to capture charge for #{payment.id}")
      end
    end
    redirect_to payment_path(payment), alert: "Error processing payment"
  rescue Stripe::CardError => e
    Rollbar.error(e)
    redirect_to payment_path(payment), alert: "Error processing payment #{e.error.message}"
  end

  def create_charge(token)
    Stripe::Charge.create(
      amount: payment.total_amount.cents,
      currency: @config.currency_code,
      description: @payment.long_description.truncate(499),
      source: token,
      metadata: metadata
    )
  end

  def metadata
    {
      payment_id: payment.id,
      details: payment.long_description
    }
  end
end
