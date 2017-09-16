# == Schema Information
#
# Table name: songs
#
#  id             :integer          not null, primary key
#  registrant_id  :integer
#  description    :string(255)
#  song_file_name :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  event_id       :integer
#  user_id        :integer
#  competitor_id  :integer
#
# Indexes
#
#  index_songs_on_competitor_id                           (competitor_id) UNIQUE
#  index_songs_on_user_id_and_registrant_id_and_event_id  (user_id,registrant_id,event_id) UNIQUE
#  index_songs_registrant_id                              (registrant_id)
#

require 'spec_helper'

describe SongsController do
  before(:each) do
    FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 4.days)
    @user = FactoryGirl.create(:user)
    @reg = FactoryGirl.create(:competitor, user: @user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Song. As you add validations to Song, be sure to
  # adjust the attributes here as well.
  let(:event) { FactoryGirl.create(:event) }
  let(:song_file) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'example.mp3'), 'audio/mp3') }
  let(:valid_attributes) { { description: "MyString", event_id: event.id, song_file_name: song_file } }

  describe "GET index" do
    it "hsows all songs for reg" do
      FactoryGirl.create(:song, registrant: @reg, description: "Description")
      get :index, params: { registrant_id: @reg.to_param }

      assert_select "tr>td", text: "Description".to_s, count: 1
    end

    it "shows a new song form" do
      get :index, params: { registrant_id: @reg.to_param }

      assert_select "form[action=?][method=?]", registrant_songs_path(@reg, locale: 'en'), "post" do
        assert_select "input#song_description[name=?]", "song[description]"
        assert_select "select#song_event_id[name=?]", "song[event_id]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Song" do
        expect do
          post :create, params: { song: valid_attributes, registrant_id: @reg.to_param }
        end.to change(Song, :count).by(1)
      end

      it "redirects to the song add_file page" do
        post :create, params: { song: valid_attributes, registrant_id: @reg.to_param }
        expect(response).to redirect_to(registrant_songs_path(@reg))
      end
    end

    describe "with invalid params" do
      it "does not create a new song" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Song).to receive(:save).and_return(false)
        expect do
          post :create, params: { song: { "description" => "invalid value" }, registrant_id: @reg.to_param }
        end.not_to change(Song, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Song).to receive(:save).and_return(false)
        post :create, params: { song: { "description" => "invalid value" }, registrant_id: @reg.to_param }
        assert_select "h1", "#{@reg}'s songs"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested song" do
      song = FactoryGirl.create(:song, registrant: @reg, user: @reg.user)
      expect do
        delete :destroy, params: { id: song.to_param }
      end.to change(Song, :count).by(-1)
    end

    it "redirects to the songs list" do
      song = FactoryGirl.create(:song, registrant: @reg, user: @reg.user)
      delete :destroy, params: { id: song.to_param }
      expect(response).to redirect_to(registrant_songs_path(@reg))
    end
  end
end
