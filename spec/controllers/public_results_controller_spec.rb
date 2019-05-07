require 'spec_helper'

describe PublicResultsController do
  let(:competition) { FactoryBot.create(:competition) }
  let(:result) { FactoryBot.create(:competition_result, competition: competition) }

  describe "GET show" do
    it "renders" do
      get :show, params: { id: result.id }
      expect(response).to be_redirect
    end
  end
end
