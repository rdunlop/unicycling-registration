# == Schema Information
#
# Table name: standard_skill_entries
#
#  id          :integer          not null, primary key
#  number      :integer
#  letter      :string(255)
#  points      :decimal(6, 2)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_standard_skill_entries_on_letter_and_number  (letter,number) UNIQUE
#

require 'spec_helper'

xdescribe StandardSkillEntriesController do
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
