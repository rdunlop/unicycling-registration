require "spec_helper"
require "request_helper"

RSpec.describe "/healthcheck", type: :request do
  it "returns 200 OK without needing a tenant or login" do
    get "/healthcheck"

    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("OK")
  end
end
