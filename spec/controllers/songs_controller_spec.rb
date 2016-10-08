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
  let(:valid_attributes) { { description: "MyString", event_id: event.id } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SongsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all songs for reg as @songs" do
      FactoryGirl.create(:song, registrant: @reg, description: "Description")
      get :index, params: { registrant_id: @reg.to_param }

      assert_select "tr>td", text: "Description".to_s, count: 1
    end

    it "assigns a new song as @song" do
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
        expect(response).to redirect_to(add_file_song_path(Song.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved song as @song" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Song).to receive(:save).and_return(false)
        post :create, params: { song: { "description" => "invalid value" }, registrant_id: @reg.to_param }
        expect(assigns(:song)).to be_a_new(Song)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Song).to receive(:save).and_return(false)
        post :create, params: { song: { "description" => "invalid value" }, registrant_id: @reg.to_param }
        expect(response).to render_template("index")
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
