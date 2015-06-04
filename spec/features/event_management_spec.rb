require 'spec_helper'

describe 'Creating a Competition from an Event' do
  let!(:user) { FactoryGirl.create(:super_admin_user) }
  include_context 'basic event configuration'
  include_context 'freestyle_event', name: "Individual"
  include_context 'user is logged in'

  before :each do
    visit competition_setup_path
  end

  describe "when on the new competition page" do
    before :each do
      within("tbody tr:first") do
        click_link "Create New Competition"
      end
    end

    it "has the new page" do
      expect(page).to have_content("Settings for printing the awards")
    end

    it "can create a new competition" do
      fill_in :competition_name, with: "The only competition"
      fill_in :competition_award_title_name, with: "The Best Competition"
      select "Freestyle", from: "Scoring Type"
      expect {
        click_button "Create Competition"
      }.to change(Competition, :count).by(1)
    end
  end
end
