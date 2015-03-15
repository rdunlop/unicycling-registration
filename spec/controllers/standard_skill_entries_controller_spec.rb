require 'spec_helper'

describe StandardSkillEntriesController do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'upload_file'" do
    it "returns error" do
      get 'upload_file'
      expect(response).to redirect_to(root_path)
    end

    it "succeeds as super_admin" do
      sign_out @user
      @super_user = FactoryGirl.create(:super_admin_user)
      sign_in @super_user

      get 'upload_file'
      expect(response).to be_success
    end
  end
end
