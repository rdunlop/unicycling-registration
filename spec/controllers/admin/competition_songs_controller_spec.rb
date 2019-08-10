require 'spec_helper'

describe Admin::CompetitionSongsController do
  let(:user) { FactoryBot.create(:super_admin_user) }
  before do
    FactoryBot.create(:event_configuration, music_submission_end_date: Date.current + 4.days)
    sign_in user
  end

  let(:competition) { FactoryBot.create(:competition) }

  describe "as a normal user" do
    before do
      sign_out user
      sign_in FactoryBot.create(:user)
    end

    it "doesn't have permission" do
      get :show, params: { competition_id: competition.id }
      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET show" do
    it "views the songs list index" do
      get :show, params: { competition_id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    let(:event) { FactoryBot.create(:event) }
    let(:competitor) { FactoryBot.create(:event_competitor) }
    let(:song) { FactoryBot.create(:song) }

    it "assigns the competitor to the song" do
      post :create, params: { competition_id: competition.to_param, song_id: song.id, competitor_id: competitor.id }
      expect(song.reload.competitor).to eq(competitor)
    end

    context "when the competitor already has a song associated" do
      let!(:old_song) { FactoryBot.create(:song, competitor: competitor) }

      it "un-assigns, and assigns to a new song" do
        post :create, params: { competition_id: competition.to_param, song_id: song.id, competitor_id: competitor.id }
        expect(song.reload.competitor).to eq(competitor)
        expect(old_song.reload.competitor).to be_nil
      end
    end
  end

  describe "GET download_zip" do
    let(:competitor) { FactoryBot.create(:event_competitor, competition: competition) }
    # NOTE: on songs

    it "loads all songs" do
      get :download_zip, params: { competition_id: competition.to_param }

      expect(response).to be_successful
    end
  end
end
