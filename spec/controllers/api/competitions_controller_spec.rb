require 'spec_helper'

describe Api::CompetitionsController do
  let(:token) { "HELLO" }
  let(:json) { JSON.parse(response.body) }

  # before do
  #   allow(Rails.configuration).to receive(:api_token).and_return("ABC123")
  # end

  def authenticate_with_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "GET index" do
    before do
      request.headers["Authorization"] = authenticate_with_token(token)
    end

    it "shows no competitions" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(json).to eq("competitions" => [])
    end

    it "shows competitions with results" do
      competition = FactoryBot.create(:competition, :published, order_finalized: true)
      FactoryBot.create(:competition_result, competition: competition)

      get :index
      expect(response).to have_http_status(:ok)
      expect(json["competitions"].count).to eq(1)
    end
  end
end
