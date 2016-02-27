require 'spec_helper'

describe CompetitionSetup::EventConfigurationsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:competition_admin_user)
    sign_in @admin_user
    @event = FactoryGirl.create(:event)
    @event_configuration = FactoryGirl.create(:event_configuration)
  end

  describe "GET edit" do
    it "assigns event_configuration as @event_configuration" do
      get :edit
      expect(assigns(:event_configuration)).to eq(@event_configuration)
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
      put :update, event_configuration: ec_attributes
      expect(@event_configuration.reload.max_award_place).to eq(4)
      expect(@event_configuration.reload.artistic_score_elimination_mode_naucc).to be_falsey
    end
  end
end
