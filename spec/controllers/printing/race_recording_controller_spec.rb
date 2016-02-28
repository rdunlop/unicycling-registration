require 'spec_helper'

describe Printing::RaceRecordingController do
  before do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end

  describe "#instructions" do
    it "renders" do
      get :instructions
      expect(response).to be_success
    end
  end

  describe "#blank" do
    it "renders" do
      get :blank
      expect(response).to be_success
    end
  end
end
