require 'spec_helper'

describe 'Judging an event' do
  let!(:user) { FactoryGirl.create(:data_entry_volunteer_user, name: "Judge User") }
  include_context 'basic event configuration'
  include_context 'freestyle_event', name: "Individual"
  include_context "judge_is_assigned_to_competition", user_name: "Judge User", competition_name: "Individual"
  include_context 'user is logged in'

  describe "user is presented with a judging menu" do
    it "is on the data entry menu option" do
      expect(page).to have_content("Data Entry")
    end

    describe "in event judging" do
      before :each do
        visit '/en/welcome/data_entry_menu'
        click_link "Individual - Presentation"
      end

      it "shows the competitor" do
        expect(page).to have_content("Robin Dunlop")
      end

      describe "when scoring competitor A" do
        it "can add and update scores" do
          click_link "Set Score"
          fill_in "score[val_1]", with: "1.0"
          fill_in "score[val_2]", with: "2.0"
          fill_in "score[val_3]", with: "3.0"
          fill_in "score[val_4]", with: "4.0"
          click_button "Save"

          expect(page).to have_content("10") # total score
          expect(Score.count).to be(1)
        end
      end
    end
  end
end
