require 'spec_helper'

describe CompetitionResultsController do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:user) { FactoryGirl.create(:super_admin_user) }
  before { sign_in user }

  describe "GET index" do
    it "renders" do
      get :index, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:result_file) { fixture_path + '/sample.pdf' }
    let(:test_data_file) { Rack::Test::UploadedFile.new(result_file, "application/pdf") }

    it "creates a result" do
      expect do
        post :create, results_file: test_data_file, custom_name: "New Results", competition_id: competition.id
      end.to change(CompetitionResult, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    let!(:result) { FactoryGirl.create(:competition_result, competition: competition) }
    it "removes the result" do
      expect do
        delete :destroy, id: result.id, competition_id: competition.id
      end.to change(CompetitionResult, :count).by(-1)
    end
  end
end
