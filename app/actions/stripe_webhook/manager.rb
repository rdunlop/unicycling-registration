# Manage the stripe webhook callbacks

module StripeWebhook
  class Manager
    WEBHOOK_NAME = "checkout.session.completed".freeze
    attr_reader :stripe_secret_key, :domain

    def initialize(stripe_secret_key, domain)
      @stripe_secret_key = stripe_secret_key
      @domain = domain
    end

    def register_callback
      set_api_key

      Stripe::WebhookEndpoint.create(
        url: url,
        enabled_events: enabled_events,
        api_version: "2019-12-03"
      )
    end

    def unregister_callback
      set_api_key
      existing_webhook = webhook?
      return unless existing_webhook

      Stripe::WebhookEndpoint.delete(existing_webhook)
    end

    # determine whether the necessary webhook exists
    # return the ID of the webhook, if present
    # return nil otherwise
    def webhook?
      set_api_key
      hooks = Stripe::WebhookEndpoint.list
      matching_hook = hooks.detect do |hook|
        hook.url == url
      end

      matching_hook&.id
    end

    private

    def set_api_key
      Stripe.api_key = @stripe_secret_key
    end

    def url
      "#{domain}/webhook/endpoint"
    end

    def enabled_events
      [
        WEBHOOK_NAME
      ]
    end
  end
end
