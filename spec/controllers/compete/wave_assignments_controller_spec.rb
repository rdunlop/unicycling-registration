require 'spec_helper'

describe Compete::WaveAssignmentsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  let(:competition) { FactoryGirl.create(:timed_competition) }

  let(:valid_attributes) { { "name" => "MyString" } }

  describe "GET show" do
    it "displays the competitors" do
      get :show, params: { competition_id: competition.id }
      expect(response).to be_success
    end

    it "downloads the xls" do
      get :show, params: { competition_id: competition.id, format: :xls }
      expect(response.content_type.to_s).to eq("application/vnd.ms-excel")
    end
  end

  describe "PUT update" do
    let(:wave_data_file_name) { fixture_path + '/sample_wave_assignments.txt' }
    let(:wave_data_file) { Rack::Test::UploadedFile.new(wave_data_file_name, "text/plain") }
    let!(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 101) }
    let!(:competitor2) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 102) }
    let!(:competitor3) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 103) }
    let!(:competitor4) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 104) }

    it "updates the waves" do
      expect(competitor1.wave).to be_nil
      put :update, params: { competition_id: competition.id, file: wave_data_file }
      expect(competitor1.reload.wave).to eq(1)
      expect(competitor2.reload.wave).to eq(1)
      expect(competitor3.reload.wave).to eq(2)
      expect(competitor4.reload.wave).to eq(2)
    end
  end
end
