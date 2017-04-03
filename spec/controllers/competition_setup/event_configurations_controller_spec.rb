require 'spec_helper'

describe CompetitionSetup::EventConfigurationsController do
  let(:max_place) { 6 }
  before(:each) do
    @admin_user = FactoryGirl.create(:competition_admin_user)
    sign_in @admin_user
    @event = FactoryGirl.create(:event)
    EventConfiguration.singleton.update(max_award_place: max_place)
  end

  describe "GET edit" do
    it "assigns event_configuration as @event_configuration" do
      get :edit
      assert_select "input[value=?]", max_place.to_s
    end
  end

  describe "PUT update" do
    let(:ec_attributes) do
      {
        artistic_score_elimination_mode_naucc: "0",
        max_award_place: "4"
      }
    end

    it "updates the EC" do
      put :update, params: { event_configuration: ec_attributes }
      event_configuration = EventConfiguration.first
      expect(event_configuration.reload.max_award_place).to eq(4)
      expect(event_configuration.reload.artistic_score_elimination_mode_naucc).to be_falsey
    end
  end
end
