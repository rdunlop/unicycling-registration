class AddStripeWebhookSecret < ActiveRecord::Migration[5.2]
  def change
    add_column :event_configurations, :stripe_webhook_secret, :string
  end
end
