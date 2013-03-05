require 'spec_helper'

describe Admin::StandardSkillEntriesController do
  before (:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET 'upload_file'" do
    it "returns http success" do
      get 'upload_file'
      response.should be_success
    end
  end

end
