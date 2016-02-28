require 'spec_helper'

describe Printing::EventsController do
  before do
    FactoryGirl.create(:event_configuration)
    user = FactoryGirl.create(:user)
    user.add_role :director, event
    sign_in user
  end
  let(:event) { FactoryGirl.create(:event) }

  describe "GET results" do
    it "renders" do
      event
      get :results, id: event.id
      expect(response).to be_success
    end
  end
end
