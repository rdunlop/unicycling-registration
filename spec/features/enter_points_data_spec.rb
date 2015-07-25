require 'spec_helper'

describe 'Entering Points data' do
  let!(:user) { FactoryGirl.create(:data_entry_volunteer_user, name: "Judge User") }
  include_context 'unpaid registration'
  include_context 'basic event configuration'
  include_context 'points_event', name: 'Basketball'
  include_context 'user is logged in'

  describe "the event on the page" do
    before :each do
      user.add_role(:data_recording_volunteer, Competition.first)
      within "#admin_bar" do
        click_link "Data Entry"
      end
    end

    specify { expect(page).to have_content("Basketball") }

    describe "when entering results" do
      before :each do
        click_link "Entry Form"
      end

      it "can add and update scores" do
        select "Robin Robin", from: 'external_result[competitor_id]'
        fill_in "external_result[points]", with: "1.0"
        fill_in "external_result[details]", with: "1 pts"

        expect do
          click_button "Create External result"
        end.to change(ExternalResult, :count).by(1)
      end
    end
  end
end
