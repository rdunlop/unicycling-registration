require 'spec_helper'

shared_context "freestyle_event" do |options = {}|
  before :each do
    event = FactoryGirl.create(:event, :name => options[:name])
    competition = FactoryGirl.create(:competition, event: event, :name => options[:name])
    FactoryGirl.create(:event_competitor, :competition => competition)
    reg = Registrant.first
    reg.first_name = "Robin"
    reg.last_name = "Robin"
    reg.save
  end
end

shared_context "judge_is_assigned_to_competition" do |options = {}|
  before :each do
    competition = Competition.first
    judge_user = User.first
    judge = FactoryGirl.create(:judge, competition: competition, user: judge_user)
    jt = judge.judge_type
    jt.name = "Presentation"
    jt.save
  end
end

describe 'Judging an event' do
  let!(:user) { FactoryGirl.create(:data_entry_volunteer_user) }
  include_context 'basic event configuration'
  include_context 'freestyle_event', :name => "Individual"
  include_context "judge_is_assigned_to_competition"
  include_context 'user is logged in'

  describe "user is presented with a judging menu" do
    it "is on the judging menu" do
      expect(page).to have_content("My Judging Events")
    end

    describe "in event judging" do
      before :each do
        click_link "Individual - Individual - Presentation"
      end

      it "shows the competitor" do
        expect(page).to have_content("Robin Dunlop")
      end

      describe "when scoring competitor A" do
        it "can add and update scores" do
          click_link "Update"
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
