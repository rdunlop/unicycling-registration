require 'spec_helper'

describe 'Entering Points data' do
  let!(:user) { FactoryGirl.create(:data_entry_volunteer_user, name: "Judge User") }
  include_context 'unpaid registration'
  include_context 'basic event configuration'
  include_context 'points_event', { name: 'Basketball' }
  include_context 'user is logged in'

  describe "the event on the page" do
    before :each do
      click_link "Data Entry"
    end

    specify { expect(page).to have_content("Basketball") }

    describe "when entering results" do
      before :each do
        click_link "Basketball"
        within "#side_nav" do
          click_link "Entry Form"
        end
      end

      it "can add and update scores" do
        select "Robin Robin", from: 'import_result[bib_number]'
        fill_in "import_result[points]", with: "1.0"
        fill_in "import_result[details]", with: "1 pts"

        expect do
          click_button "Submit"
        end.to change(ImportResult, :count).by(1)
      end
    end
  end
end
