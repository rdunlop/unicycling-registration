require 'spec_helper'

describe CompetitionSetup::DirectorsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:competition_admin_user)
    sign_in @admin_user
    @event = FactoryGirl.create(:event)
    @event_category = @event.event_categories.first
  end

  describe "GET index" do
    it "assigns the events as @events" do
      get :index
      expect(assigns(:events)).to eq([@event])
    end
  end

  describe "POST create" do
    it "assigns the requested user as director" do
      user = FactoryGirl.create(:user)
      post :create, params: { user_id: user.id, event_id: @event.id }
      expect(user.reload.roles.count).to eq(1)
    end
  end

  describe "DELETE destroy" do
    it "removes users role" do
      user = FactoryGirl.create(:user)
      user.add_role(:director, @event)
      delete :destroy, params: { id: user.id, event_id: @event.id }
      expect(user.reload.roles.count).to eq(0)
    end
  end
end
