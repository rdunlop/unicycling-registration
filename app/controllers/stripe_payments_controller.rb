class StripePaymentsController < ApplicationController
  before_action :skip_authorization
  skip_before_action :verify_authenticity_token

  # Stripe post-back endpoint
  def stripe
    process_notification
    head :ok
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

    # Should add metadata, and update the amount, etc etc.
    Stripe::Charge.create(
      amount: payment.total.cents,
      currency: @config.currency_code,
      description: @payment.long_description,
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
