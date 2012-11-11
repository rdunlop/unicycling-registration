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
    before(:each) do
      @ec1 = FactoryGirl.create(:event_choice)
      @attributes = {
        "#{@ec1.id}" => "1"
      }
    end
    it "returns http success" do
      post 'create', {:id => @reg, :event_choices => @attributes}
      response.should redirect_to (@reg)
    end

    it "creates a corresponding event_choice when checkbox is selected" do
      post 'create', {:id => @reg, :event_choices => @attributes}
      RegistrantChoice.count.should == 1
    end
    it "doesn't create a new entry if one already exists" do
      RegistrantChoice.count.should == 0
      post 'create', {:id => @reg, :event_choices => @attributes}
      post 'create', {:id => @reg, :event_choices => @attributes}
      RegistrantChoice.count.should == 1
    end
  end
end
