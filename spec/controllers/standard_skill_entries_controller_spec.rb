# == Schema Information
#
# Table name: standard_skill_entries
#
#  id                        :integer          not null, primary key
#  number                    :integer
#  letter                    :string(255)
#  points                    :decimal(6, 2)
#  description               :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  friendly_description      :text
#  additional_description_id :integer
#  skill_speed               :string
#  skill_before_id           :integer
#  skill_after_id            :integer
#
# Indexes
#
#  index_standard_skill_entries_on_letter_and_number  (letter,number) UNIQUE
#

require 'spec_helper'

describe StandardSkillEntriesController do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'index'" do
    it "returns http success" do
      FactoryGirl.create(:standard_skill_entry, description: "first skill")
      get :index
      expect(response).to be_success

      assert_match(/first skill/, response.body)
    end
  end
end
