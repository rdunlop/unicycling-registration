require 'spec_helper'

describe Printing::EventsController do
  before do
    FactoryBot.create(:event_configuration)
    user = FactoryBot.create(:user)
    user.add_role :director, event
    sign_in user
  end

  let(:event) { FactoryBot.create(:event) }

  describe "GET results" do
    it "renders" do
      event
      get :results, params: { id: event.id }
      expect(response).to be_successful
    end
  end
end
