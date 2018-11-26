class AddStripeSupport < ActiveRecord::Migration[5.1]
  def change
    add_column :event_configurations, :stripe_public_key, :string
    add_column :event_configurations, :stripe_secret_key, :string
  end
end
