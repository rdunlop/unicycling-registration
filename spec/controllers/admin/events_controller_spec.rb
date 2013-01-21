require 'spec_helper'

describe Admin::EventsController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end

  describe "GET index" do
    it "assigns all events as @events" do
      event = FactoryGirl.create(:event)
      get :index, {}
      response.should be_success
      assigns(:events).should eq([event])
    end
    describe "With competitors and non-competitors" do
      before(:each) do
        @comp1 = FactoryGirl.create(:competitor)
        @comp2 = FactoryGirl.create(:competitor)
        @non_comp1 = FactoryGirl.create(:noncompetitor)
      end
      it "sets the number of registrants as @num_registrants" do
        get :index, {}
        assigns(:num_registrants).should == 3
      end
      it "sets the number of competitors as @num_competitors" do
        get :index, {}
        assigns(:num_competitors).should == 2
      end
      it "sets the number of non_competitors as @num_non_competitors" do
        get :index, {}
        assigns(:num_non_competitors).should == 1
      end
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      event = FactoryGirl.create(:event)
      get :show, {:id => event.to_param}
      assigns(:event).should == event
    end
  end
end
