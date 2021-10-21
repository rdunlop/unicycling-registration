require 'spec_helper'

describe 'Logging in to the system' do
  let(:user) { FactoryBot.create :user }

  include_context 'basic event configuration'
  include_context 'user is logged in'

  describe "when creating a new noncompetitor" do
    specify 'can create new noncompetitor' do
      expect(page).to have_content 'Create New Non-Competitor'
    end

    context 'within the new_competitor form' do
      before do
        click_link 'Create New Non-Competitor'
      end

      context 'filling in the neccesary information' do
        include_context 'basic registrant data'
        before do
          within "#tabs-new-registrant" do
            click_button 'Save & Continue'
          end
        end

        it "creates a registrant" do
          expect(user.reload.registrants.count).to eq(1)
        end
      end
    end
  end

  context 'within the new competitor form' do
    before do
      click_link 'Create New Competitor'
    end

    context 'filling in the necessary information' do
      include_context 'basic registrant data'
      before do
        within "#tabs-new-registrant" do
          click_button 'Save & Continue'
        end
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
        before do
          click_button "Save & Continue" # on volunteer page
        end

        context "blah" do
          include_context "basic address data"
          before do
            click_button "Save & Continue"
          end

          it "is on the expenses page" do
            expect(page.current_path).to match(/build\/expenses/)
          end
        end
      end
    end
  end

  describe "when a noncompetitor registrant exists" do
    before do
      registrant = FactoryBot.create(:noncompetitor, user: user)
      visit registrant_path(registrant)
    end

    it "displays the summary page" do
      expect(page).to have_content 'Registration Summary'
      expect(page).not_to have_content 'Events'
    end
  end

  describe "when registering a non-competitor" do
    before do
      comp_reg_cost = RegistrationCost.for_type("competitor").first
      comp_reg_cost.update(start_date: 2.years.ago, end_date: 1.year.ago)
    end

    context "when filling in registration" do
      before do
        click_link 'Create New Non-Competitor'
      end

      include_context "basic registrant data"

      it "can save the record" do
        within "#tabs-new-registrant" do
          click_button 'Save & Continue'
        end
        expect(user.reload.registrants.count).to eq(1)
      end
    end
  end
end
