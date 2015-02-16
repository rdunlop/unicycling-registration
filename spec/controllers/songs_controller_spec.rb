require 'spec_helper'

describe SongsController do
  before(:each) do
    FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 4.days)
    @user = FactoryGirl.create(:user)
    @reg = FactoryGirl.create(:competitor, :user => @user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Song. As you add validations to Song, be sure to
  # adjust the attributes here as well.
  let(:event) { FactoryGirl.create(:event) }
  let(:valid_attributes) { { :description => "MyString", :event_id => event.id } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SongsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all songs for reg as @songs" do
      song = FactoryGirl.create(:song, :registrant => @reg)
      get :index, {:registrant_id => @reg.to_param}
      assigns(:songs).should eq([song])
    end
    it "assigns a new song as @song" do
      get :index, {:registrant_id => @reg.to_param}
      assigns(:song).should be_a_new(Song)
    end
  end

  describe "GET list" do
    it "loads all songs" do
      get :list
      response.should redirect_to(root_url)
    end
    describe "as an admin" do
      before :each do
        sign_out @user
        sign_in FactoryGirl.create(:admin_user)
      end
      it "views the songs list" do
        song = FactoryGirl.create(:song, :registrant => @reg)
        get :list
        assigns(:songs).should eq([song])
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Song" do
        expect {
          post :create, {:song => valid_attributes, :registrant_id => @reg.to_param}
        }.to change(Song, :count).by(1)
      end

      it "redirects to the song add_file page" do
        post :create, {:song => valid_attributes, :registrant_id => @reg.to_param}
        response.should redirect_to(add_file_song_path(Song.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved song as @song" do
        # Trigger the behavior that occurs when invalid params are submitted
        Song.any_instance.stub(:save).and_return(false)
        post :create, {:song => { "description" => "invalid value" }, :registrant_id => @reg.to_param}
        assigns(:song).should be_a_new(Song)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Song.any_instance.stub(:save).and_return(false)
        post :create, {:song => { "description" => "invalid value" }, :registrant_id => @reg.to_param}
        response.should render_template("index")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested song" do
      song = FactoryGirl.create(:song, registrant: @reg, user: @reg.user)
      expect {
        delete :destroy, {:id => song.to_param}
      }.to change(Song, :count).by(-1)
    end

    it "redirects to the songs list" do
      song = FactoryGirl.create(:song, registrant: @reg, user: @reg.user)
      delete :destroy, {:id => song.to_param}
      response.should redirect_to(registrant_songs_path(@reg))
    end
  end

end
