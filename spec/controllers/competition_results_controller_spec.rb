# == Schema Information
#
# Table name: competition_results
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  results_file   :string(255)
#  system_managed :boolean          default(FALSE), not null
#  published      :boolean          default(FALSE), not null
#  published_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#

require 'spec_helper'

describe CompetitionResultsController do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:user) { FactoryGirl.create(:super_admin_user) }
  before { sign_in user }

  describe "GET index" do
    it "renders" do
      get :index, params: { competition_id: competition.id }
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:result_file) { fixture_path + '/sample.pdf' }
    let(:test_data_file) { Rack::Test::UploadedFile.new(result_file, "application/pdf") }

    it "creates a result" do
      expect do
        post :create, params: { results_file: test_data_file, custom_name: "New Results", competition_id: competition.id }
      end.to change(CompetitionResult, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    let!(:result) { FactoryGirl.create(:competition_result, competition: competition) }
    it "removes the result" do
      expect do
        delete :destroy, params: { id: result.id, competition_id: competition.id }
      end.to change(CompetitionResult, :count).by(-1)
    end
  end
end
