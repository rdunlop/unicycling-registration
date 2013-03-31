require 'spec_helper'

describe Admin::ExportController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET download_event_configuration" do
    describe "with no dota" do
      it "returns no entries for age_group_types" do
        get :download_event_configuration, {:format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == { "age_group_types" => [] }
      end
    end
    describe "with a single age_group_type and age_group_entry" do
      before(:each) do
        @agt = FactoryGirl.create(:age_group_type)
        @age = FactoryGirl.create(:age_group_entry, :age_group_type => @agt, :long_description => "long", :short_description => "short")
      end
      it "returns the single age_group_type, with embedded age_group_entry" do
        get :download_event_configuration, {:format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == {
          "age_group_types" => [
            { "description" => @agt.description,
              "name" => @agt.name,
              "age_group_entries" => [
                { "start_age" => 1,
                  "end_age" => 100,
                  "gender" => "Male",
                  "short_description" => "short",
                  "long_description" => "long"
                 }
              ]
            }
          ] }
      end
    end
  end

  describe "POST upload_event_configuration" do
    before(:each) do
      @data = {"age_group_types" => []}
    end
    # set the included data as json
    let(:submit) { {:convert => {:data => @data.to_json} } }

    describe "with no data" do
      it "creates no models" do
        post :upload_event_configuration, submit
      end
    end
    describe "with a single age_group_type" do
      before(:each) do
        @data["age_group_types"] = [{"name" => "MyGroup", "description" => "desc", "age_group_entries" => []}]
      end
      it "creates the age_group_type" do
        expect {
          post :upload_event_configuration, submit
        }.to change(AgeGroupType, :count).by(1)
        flash[:notice].should == "created AgeGroupType: MyGroup\n"
      end
      it "doesn't create the age_group_type if one already exists with that name" do
        FactoryGirl.create(:age_group_type, :name => "MyGroup")
        expect {
          post :upload_event_configuration, submit
        }.to change(AgeGroupType, :count).by(0)
      end
      describe "with a single age_group_entry in that type" do
        before(:each) do
          @data["age_group_types"][0]["age_group_entries"] = [{ "start_age" => 1,
            "end_age" => 100,
            "gender" => "Male",
            "short_description" => "short",
            "long_description" => "long"
          }]
        end
        it "creates a AgeGroupEntry" do
          expect {
            post :upload_event_configuration, submit
          }.to change(AgeGroupEntry, :count).by(1)
        end
        describe "when the age_group_type already exists" do
          before(:each) do
            @agt = FactoryGirl.create(:age_group_type, :name => "MyGroup")
          end
          it "associates with the existing agt" do
            expect {
              post :upload_event_configuration, submit
            }.to change(AgeGroupEntry, :count).by(1)
            @agt.age_group_entries.count.should == 1
            flash[:notice].should == "created AgeGroupEntry: short\n"
          end
        end
        describe "when the age_group_entry exists, for a different age_group_type" do
          before(:each) do
            FactoryGirl.create(:age_group_entry, :short_description => "short")
          end
          it "should create the age_group_entry" do
            expect {
              post :upload_event_configuration, submit
            }.to change(AgeGroupEntry, :count).by(1)
          end
        end
      end
    end
  end


  describe "GET download_events" do
    it "without any events or registrants, only prints the headers" do
      get :download_events, {:format => 'pdf' }
      assigns(:data).should == [["Registrant Name", "Age", "Gender"]]
    end
    describe "with some events defined" do
      before(:each) do
        @ev = FactoryGirl.create(:event)
      end
      it "lists the event titles" do
        get :download_events, {:format => 'pdf' }
        data = assigns(:data)
        data[0].should == ["Registrant Name", "Age", "Gender", @ev.event_categories.first.to_s]
      end
      it "lists the each event_choice separately, with event-prefixed" do
        get :download_events, {:format => 'pdf' }
        ec = EventCategory.all.first
        data = assigns(:data)
        data[0].should == ["Registrant Name", "Age", "Gender", ec.to_s]
      end

      describe "with a competitor" do
        before(:each) do
          @reg = FactoryGirl.create(:competitor)
        end
        it "has a row for that competitor" do
          get :download_events, {:format => 'pdf' }
          data = assigns(:data)
          data[1].should == [@reg.name, @reg.age, @reg.gender, nil]
        end
        describe "with a registration choice for the event" do
          before(:each) do
            @ecat = @ev.event_categories.first
            @rc = FactoryGirl.create(:registrant_event_sign_up, :registrant => @reg, :event_category => @ecat, :event => @ev, :signed_up => true)
          end
          it "has a value in the target column" do
            get :download_events, {:format => 'pdf' }
            data = assigns(:data)
            data[1][3].should == true
          end
        end
      end
    end
  end
end
