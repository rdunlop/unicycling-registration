require 'spec_helper'

describe CompetitionsController do
  before(:each) do
    @admin_user =FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
    @event = FactoryGirl.create(:event)
    @event_category = @event.event_categories.first
  end

  describe "POST lock" do
    it "locks the competition" do
      competition = FactoryGirl.create(:competition, :event => @event)
      post :lock, {:id => competition.to_param}
      competition.reload
      expect(competition.locked?).to eq(true)
    end
  end
  describe "DELETE lock" do
    it "unlocks the competition" do
      competition = FactoryGirl.create(:competition, event: @event, locked: true)
      delete :unlock, {:id => competition.to_param}
      competition.reload
      expect(competition.locked?).to eq(false)
    end
  end

  describe "POST publish" do
    it "publishes the competition results" do
      competition = FactoryGirl.create(:competition, event: @event, locked: true)
      post :publish, {:id => competition.to_param}
      competition.reload
      expect(competition.published?).to eq(true)
    end
  end
  describe "DELETE publish" do
    it "un-publishes the competition" do
      competition = FactoryGirl.create(:competition, event: @event, locked: true, published: true)
      delete :unpublish, {:id => competition.to_param}
      competition.reload
      expect(competition.published?).to eq(false)
    end
  end
end
