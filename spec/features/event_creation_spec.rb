require 'spec_helper'

describe 'Creating an Event' do
  let!(:user) { FactoryGirl.create(:super_admin_user) }
  include_context 'basic event configuration'
  include_context 'user is logged in'

  before :each do
    visit convention_setup_path
  end

  describe "when on the new event page" do
    before do
      within "#side_content" do
        click_link "Events"
      end
    end

    it "can create a category" do
      fill_in :category_name, with: "Artistic"
      expect { click_button("Create Category") }.to change(Category, :count).by(1)
    end

    context "from the events page" do
      before do
        within "#side_content" do
          click_link "Events"
        end
      end

      it "can create an event" do
        fill_in :event_name, with: "New Event"
        fill_in "Event Category Name", with: "All"
        expect { click_button("Create Event") }.to change(Event, :count).by(1)
      end
    end
  end
end
