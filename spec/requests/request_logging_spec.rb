require "spec_helper"
require "request_helper"

RSpec.describe "request logging", type: :request do
  # Captures the JSON lines lograge writes for requests made inside the block.
  def lograge_lines
    io = StringIO.new
    original = Lograge.logger
    Lograge.logger = ActiveSupport::Logger.new(io)
    yield
    io.string.lines.filter_map do |line|
      JSON.parse(line)
    rescue StandardError
      nil
    end
  ensure
    Lograge.logger = original
  end

  it "records the client IP from X-Forwarded-For, the user agent and the filtered path" do
    entries = lograge_lines do
      get "/users/sign_in?foo=bar&reset_password_token=super-secret-token",
          headers: { "User-Agent" => "TestAgent/1.0", "X-Forwarded-For" => "203.0.113.7, 10.0.0.5" }
    end

    entry = entries.find { |e| e["controller"] == "Devise::SessionsController" }

    expect(entry).to be_present
    expect(entry["ip"]).to eq("203.0.113.7")
    expect(entry["forwarded_for"]).to eq("203.0.113.7, 10.0.0.5")
    expect(entry["user_agent"]).to eq("TestAgent/1.0")
    expect(entry["host"]).to be_present
    expect(entry["path_with_query"]).to include("foo=bar")
    expect(entry["path_with_query"]).not_to include("super-secret-token")
    expect(entry).to have_key("user_id")
  end
end
