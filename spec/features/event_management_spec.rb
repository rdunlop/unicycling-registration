require 'spec_helper'

shared_context "freestyle_event" do |options = {}|
  before :each do
    event = FactoryGirl.create(:event, :name => options[:name])
    competition = FactoryGirl.create(:competition, event: event, :name => options[:name])
  end
end

describe 'Creating a Competition from an Event' do
  let!(:user) { FactoryGirl.create(:super_admin_user) }
  include_context 'basic event configuration'
  include_context 'freestyle_event', :name => "Individual"
  include_context 'user is logged in'

  before :each do
    visit event_path(Event.last)
  end

  it "is on the judging menu" do
    expect(page).to have_content("Manage Individual Competitions")
  end

  describe "when on the new competition page" do
    before :each do
      click_link "Create New Competition"
    end

    it "has the new page" do
      expect(page).to have_content("Settings for printing the awards")
    end

    it "can create a new competition" do
      fill_in :competition_name, with: "The only competition"
      select "Distance", from: "Scoring class"
      expect {
        click_button "Create Competition"
      }.to change(Competition, :count).by(1)
    end
  end
end
