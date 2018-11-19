class StripePaymentsController < ApplicationController
  before_action :skip_authorization
  skip_before_action :verify_authenticity_token

  # Stripe post-back endpoint
  def stripe
    process_notification
    head :ok
  end

  private

  def process_notification
    Stripe.api_key = @config.stripe_secret_key

    # Token is created using Checkout or Elements!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]

    # Should add metadata, and update the amount, etc etc.
    charge = Stripe::Charge.create(
      amount: 999,
      currency: 'usd',
      description: 'Example charge',
      source: token
    )
  end
end
