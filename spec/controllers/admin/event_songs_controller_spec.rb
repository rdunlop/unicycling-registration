require 'spec_helper'

describe Admin::EventSongsController do
  let(:user) { FactoryGirl.create(:super_admin_user) }
  before(:each) do
    FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 4.days)
    sign_in user
  end

  describe "as a normal user" do
    before do
      sign_out user
      sign_in FactoryGirl.create(:user)
    end

    it "doesn't have permission" do
      get :index
      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET index" do
    it "views the songs list index" do
      get :index
      expect(response).to be_success
    end
  end

  describe "GET show" do
    let(:event) { FactoryGirl.create(:event) }
    let!(:song) { FactoryGirl.create(:song, event: event, description: "Description")}

    it "loads the page" do
      get :show, params: { id: event.to_param }
      expect(response).to be_success

      assert_select "tr>td", text: "Description".to_s, count: 1
    end
  end

  describe "GET all" do
    it "loads all songs" do
      get :all
      expect(response).to be_success
    end
  end
end
