require 'spec_helper'

describe Admin::ExportController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET download_events" do
    it "without any events or registrants, only prints the headers" do
      get :download_events, {:format => 'xls' }
      assigns(:data).should == [["Registrant Name", "Age", "Gender"]]
    end
    describe "with some events defined" do
      before(:each) do
        @ev = FactoryGirl.create(:event)
      end
      it "lists the event titles" do
        get :download_events, {:format => 'xls' }
        data = assigns(:data)
        data[0].should == ["Registrant Name", "Age", "Gender", @ev.event_categories.first.to_s]
      end
      it "lists the each event_choice separately, with event-prefixed" do
        get :download_events, {:format => 'xls' }
        ec = EventCategory.all.first
        data = assigns(:data)
        data[0].should == ["Registrant Name", "Age", "Gender", ec.to_s]
      end

      describe "with a competitor" do
        before(:each) do
          @reg = FactoryGirl.create(:competitor)
        end
        it "has a row for that competitor" do
          get :download_events, {:format => 'xls' }
          data = assigns(:data)
          data[1].should == [@reg.name, @reg.age, @reg.gender, nil]
        end
        describe "with a registration choice for the event" do
          before(:each) do
            @ecat = @ev.event_categories.first
            @rc = FactoryGirl.create(:registrant_event_sign_up, :registrant => @reg, :event_category => @ecat, :event => @ev, :signed_up => true)
          end
          it "has a value in the target column" do
            get :download_events, {:format => 'xls' }
            data = assigns(:data)
            data[1][3].should == true
          end
        end
      end
    end
  end
end
