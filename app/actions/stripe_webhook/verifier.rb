# Manage the stripe webhook callbacks

module StripeWebhook
  # verify that a received webhook is authentic
  class Verifier
    attr_reader :webhook_secret

    def initialize(webhook_secret:)
      @webhook_secret = webhook_secret
    end

    # check that the event is authentic
    # and return av event object
    # return false if invalid
    def verify_and_decode(body:, headers:)
      header = headers["Stripe-Signature"]
      begin
        event = Stripe::Webhook.construct_event(
          body, header, webhook_secret
        )
      rescue JSON::ParserError => e
        Rollbar.error(e)
        # Invalid payload
        return false
      rescue Stripe::SignatureVerificationError => e
        Rollbar.error(e)
        # Invalid signature
        return false
      end

      event
    end
  end
end
