require "spec_helper"
require "rack/mock"

# Tests the middleware class directly. The initializer only inserts it when
# BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD are set at boot, so this doesn't
# depend on the test environment's ENV.
RSpec.describe BasicAuthExceptHealthcheck do
  let(:inner_app) { ->(_env) { [200, { "Content-Type" => "text/plain" }, ["inner"]] } }
  let(:app) do
    described_class.new(inner_app, "Restricted") do |username, password|
      username == "staging-user" && password == "staging-pass"
    end
  end
  let(:request) { Rack::MockRequest.new(app) }
  let(:good_auth) { { "HTTP_AUTHORIZATION" => "Basic #{Base64.strict_encode64('staging-user:staging-pass')}" } }

  it "asks for credentials on the site" do
    response = request.get("/")

    expect(response.status).to eq(401)
    expect(response.headers["WWW-Authenticate"]).to include("Restricted")
  end

  it "lets the correct credentials through" do
    response = request.get("/", good_auth)

    expect(response.status).to eq(200)
    expect(response.body).to eq("inner")
  end

  it "rejects wrong credentials" do
    bad = { "HTTP_AUTHORIZATION" => "Basic #{Base64.strict_encode64('staging-user:wrong')}" }

    expect(request.get("/", bad).status).to eq(401)
  end

  it "lets the ELB health check through without credentials" do
    response = request.get("/healthcheck")

    expect(response.status).to eq(200)
    expect(response.body).to eq("inner")
  end

  it "does not exempt paths that only start with /healthcheck" do
    expect(request.get("/healthcheck/extra").status).to eq(401)
  end
end
