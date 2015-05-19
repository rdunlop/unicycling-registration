require 'spec_helper'

describe Admin::SongsController do
  before(:each) do
    FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 4.days)
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET list" do
    it "loads all songs" do
      get :list
      expect(response).to redirect_to(root_url)
    end
    describe "as an admin" do
      before :each do
        sign_out @user
        sign_in FactoryGirl.create(:admin_user)
      end
      it "views the songs list" do
        song = FactoryGirl.create(:song)
        get :list
        expect(assigns(:songs)).to eq([song])
      end
    end
  end
end
