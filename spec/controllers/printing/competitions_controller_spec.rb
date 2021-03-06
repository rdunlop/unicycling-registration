require 'spec_helper'

describe Printing::CompetitionsController do
  before do
    FactoryBot.create(:event_configuration)
    user = FactoryBot.create(:super_admin_user)
    sign_in user
  end

  let(:competition) { FactoryBot.create(:competition) }

  describe "GET announcer" do
    it "renders" do
      get :announcer, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "GET start_list" do
    it "renders" do
      get :start_list, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "GET heat_recording" do
    it "renders" do
      get :heat_recording, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "GET single_attempt_recording" do
    it "renders" do
      get :single_attempt_recording, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "GET two_attempt_recording" do
    it "renders" do
      get :two_attempt_recording, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "GET results" do
    it "renders" do
      get :results, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "GET freestyle_summary" do
    let(:competition) { FactoryBot.create(:competition, :freestyle_2017) }

    it "renders" do
      get :freestyle_summary, params: { id: competition.id }
      expect(response).to be_successful
    end
  end
end
