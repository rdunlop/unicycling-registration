require "spec_helper"
require "request_helper"

RSpec.describe "/healthcheck", type: :request do
  it "returns 200 without needing a tenant or login" do
    get "/healthcheck"

    expect(response).to have_http_status(:ok)
  end
end
