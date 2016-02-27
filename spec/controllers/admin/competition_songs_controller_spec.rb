require 'spec_helper'

describe Admin::CompetitionSongsController do
  let(:user) { FactoryGirl.create(:super_admin_user) }
  before(:each) do
    FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 4.days)
    sign_in user
  end
  let(:competition) { FactoryGirl.create(:competition) }

  describe "as a normal user" do
    before do
      sign_out user
      sign_in FactoryGirl.create(:user)
    end

    it "doesn't have permission" do
      get :show, competition_id: competition.id
      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET show" do
    it "views the songs list index" do
      get :show, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:event) { FactoryGirl.create(:event) }
    let(:competitor) { FactoryGirl.create(:event_competitor) }
    let(:song) { FactoryGirl.create(:song) }

    it "assigns the competitor to the song" do
      post :create, competition_id: competition.to_param, song_id: song.id, competitor_id: competitor.id
      expect(song.reload.competitor).to eq(competitor)
    end
  end

  describe "GET download_zip" do
    let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }
    let!(:song) { FactoryGirl.create(:song, competitor: competitor) }

    it "loads all songs" do
      get :download_zip, competition_id: competition.to_param
      expect(response).to be_success
    end
  end
end
