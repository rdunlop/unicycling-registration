require 'spec_helper'

describe CompetitionSetup::DirectorsController do
  before do
    @admin_user = FactoryBot.create(:competition_admin_user)
    sign_in @admin_user
    @event = FactoryBot.create(:event)
    @event_category = @event.event_categories.first
  end

  describe "GET index" do
    it "shows the events" do
      get :index

      assert_select "td", @event.to_s
    end
  end

  describe "POST create" do
    it "assigns the requested users as directors" do
      user = FactoryBot.create(:user)
      post :create, params: { users_id: [user.id], events_id: [@event.id] }
      expect(user.reload.roles.count).to eq(1)
    end
  end

  describe "DELETE destroy" do
    it "removes users role" do
      user = FactoryBot.create(:user)
      user.add_role(:director, @event)
      delete :destroy, params: { id: user.id, event_id: @event.id }
      expect(user.reload.roles.count).to eq(0)
    end
  end
end
