# Handles receipt of a completed stripe checkout session
# marks the related payment completed
class StripeWebhooksController < ApplicationController
  before_action :skip_authorization
  skip_before_action :verify_authenticity_token

  # Stripe webhook endpoint on receipt of a webhook
  def create
    unless @config.payment_type == "advanced_stripe"
      Rollbar.error("Received stripe webhook without a configured secret", tenant: Apartment::Tenant.current)
      return head :not_found
    end

    verifier = StripeWebhook::Verifier.new(webhook_secret: @config.stripe_webhook_secret)
    event = verifier.verify_and_decode(body: request.body.read, headers: request.headers)

    unless event
      Rollbar.error("Received invalid stripe event", tenant: Apartment::Tenant.current)
      return head :not_found
    end

    case event.type
    when StripeWebhook::Manager::WEBHOOK_NAME
      process_checkout_session(event.data.object)
    end

    head :ok
  end

  private

  # find the associated payment, and mark it as complete
  def process_checkout_session(checkout_session)
    invoice_id = checkout_session.client_reference_id

    payment = Payment.find_by(invoice_id: invoice_id)

    if payment.nil?
      PaymentMailer.ipn_received("Stripe Payment not found for invoice_id #{invoice_id}").deliver_later
      return
    end

    if payment.completed
      PaymentMailer.ipn_received("Stripe Payment already completed. Invoice ID: #{payment.invoice_id}").deliver_later
      return
    end
    payment_intent_id = checkout_session.payment_intent

    payment.complete(transaction_id: payment_intent_id, payment_date: Time.current)
    PaymentMailer.payment_completed(payment).deliver_later
  end
end
