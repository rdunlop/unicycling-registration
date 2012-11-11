require 'spec_helper'

describe AttendingController do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', {:id => @reg}
      response.should be_success
    end

    it "returns a list of all of the events" do
      @event1 = FactoryGirl.create(:event, :position => 1)
      @event3 = FactoryGirl.create(:event, :position => 3)
      @event2 = FactoryGirl.create(:event, :position => 2)

      get 'new', {:id => @reg}
      assigns(:events).should == [@event1, @event2, @event3]
    end
  end

  describe "POST 'create'" do
    it "returns http success" do
      get 'create', {:id => @reg}
      response.should redirect_to (@reg)
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit', {:id => @reg}
      response.should be_success
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      put 'update', {:id => @reg}
      response.should redirect_to(@reg)
    end
  end

end
