require 'spec_helper'

describe 'Logging in to the system' do
  let(:user) { FactoryGirl.create :user }
  include_context 'basic event configuration'
  include_context 'user is logged in'

  describe "when creating a new noncompetitor" do
    specify 'can create new noncompetitor' do
      expect(page).to have_content 'Create New Non-Competitor'
    end

    context 'within the new_competitor form' do
      before { click_link 'Create New Non-Competitor' }

      context 'filling in the neccesary information' do
        include_context 'basic registrant data'
        before :each do
          click_button 'Save & Continue'
        end

        it "creates a registrant" do
          expect(user.reload.registrants.count).to eq(1)
        end
      end
    end
  end

  context 'within the new competitor form' do
    before { click_link 'Create New Competitor' }

    context 'filling in the necessary information' do
      include_context 'basic registrant data'
      before :each do
        click_button 'Save & Continue'
        check '100m'
        click_button 'Save & Continue'
      end

      it "creates a registrant" do
        expect(user.reload.registrants.count).to eq(1)
      end

      it "associates the registration period cost" do
        expect(user.reload.registrants.first.registrant_expense_items.count).to eq(1)
      end

      describe "when filling in volunteer, and address info" do
        before :each do
          click_button "Save & Continue" # on volunteer page
        end

        context "blah" do
          include_context "basic address data"
          before :each do
            click_button "Save & Continue"
          end

          it "is on the expenses page" do
            expect(page.current_path).to match(/build\/expenses/)
          end
        end
      end
    end
  end

  describe "when a competitor registrant exists" do
    before :each do
      registrant = FactoryGirl.create(:competitor, :user => user)
      visit registrant_path(registrant)
    end

    it "displays the summary page" do
      expect(page).to have_content 'Registration Summary'
    end

    describe "and creating another registrant" do
      before :each do
        visit new_registrant_path(registrant_type: 'non_competitor')
      end

      it "should display the form" do
        expect(page).to have_content("Non-Competitor")
      end
    end
  end

  describe "when a noncompetitor registrant exists" do
    before :each do
      registrant = FactoryGirl.create(:noncompetitor, :user => user)
      visit registrant_path(registrant)
    end

    it "displays the summary page" do
      expect(page).to have_content 'Registration Summary'
      expect(page).to_not have_content 'Events'
    end
  end
end
