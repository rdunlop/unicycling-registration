require "spec_helper"
require "request_helper"

RSpec.describe "rack attack throttling", type: :request do
  around do |example|
    original_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true
    # Rack::Attack counts in fixed windows keyed by Time.now. Freezing the clock
    # keeps one example's requests in one window, so it can't straddle a
    # minute boundary (slow password hashing makes that likely).
    freeze_time
    example.run
  ensure
    travel_back
    Rack::Attack.enabled = false
    Rack::Attack.cache.store = original_store
  end

  let(:sign_in_params) { { user: { email: "nobody@example.com", password: "wrong-password" } } }

  it "limits sign-in attempts per IP" do
    10.times { post "/users/sign_in", params: sign_in_params }
    expect(response).not_to have_http_status(429)

    post "/users/sign_in", params: sign_in_params
    expect(response).to have_http_status(429)
  end

  it "counts locale-prefixed paths towards the same limit" do
    10.times { post "/en/users/sign_in", params: sign_in_params }
    expect(response).not_to have_http_status(429)

    post "/da/users/sign_in", params: sign_in_params
    expect(response).to have_http_status(429)
  end

  it "limits password reset requests for one email address" do
    reset_params = { user: { email: "someone@example.com" } }

    5.times { post "/users/password", params: reset_params }
    expect(response).not_to have_http_status(429)

    post "/users/password", params: reset_params
    expect(response).to have_http_status(429)
  end

  it "logs each throttled request with the rule that matched and no email address" do
    10.times { post "/users/sign_in", params: sign_in_params }

    allow(Rails.logger).to receive(:warn)

    post "/users/sign_in", params: sign_in_params

    expect(Rails.logger).to have_received(:warn).with(
      a_string_including('"event":"rack_attack.throttled"', '"rule":"users/sign_in/ip"')
    )
  end

  it "keeps the health check reachable while throttling is on" do
    10.times { post "/users/sign_in", params: sign_in_params }
    post "/users/sign_in", params: sign_in_params
    expect(response).to have_http_status(429)

    get "/healthcheck"
    expect(response).to have_http_status(:ok)
  end
end
