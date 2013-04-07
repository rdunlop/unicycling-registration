require 'spec_helper'

describe Admin::ExportController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET download_event_configuration" do
    describe "with no data" do
      it "returns no entries for age_group_types" do
        get :download_event_configuration, {:format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == { "age_group_types" => [] }
      end
    end
    describe "with a single age_group_type and age_group_entry" do
      before(:each) do
        @agt = FactoryGirl.create(:age_group_type)
        @ws = FactoryGirl.create(:wheel_size_20)
        @age = FactoryGirl.create(:age_group_entry, :age_group_type => @agt, :long_description => "long", :short_description => "short", :wheel_size => @ws)
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
                  "wheel_size_name" => "20\" Wheel",
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
        flash[:notice].should == "Created 1 records"
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
            "wheel_size_name" => nil,
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
            flash[:notice].should == "Created 1 records"
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
        describe "when the wheel_size is specified" do
          before(:each) do
            @data["age_group_types"][0]["age_group_entries"][0]["wheel_size_name"] = "16\" Wheel"
          end
          it "creates a new WheelSize" do
            expect {
              post :upload_event_configuration, submit
            }.to change(WheelSize, :count).by(1)
          end
        end
      end
    end
  end

  describe "GET download_registrants" do
    describe "with no data" do
      it "returns no entries for registranst" do
        get :download_registrants, {:format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == { "registrants" => [] }
      end
    end
    describe "with a single registrant and user" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, :birthday => Date.new(1982, 05, 20))
      end
      it "returns the single registrant, with associated user email" do
        get :download_registrants, {:format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == {
          "registrants" => [
            { "first_name" => @reg.first_name,
              "last_name" => @reg.last_name,
              "gender" => @reg.gender,
              "birthday" => "1982-05-20",
              "bib_number" => @reg.bib_number,
              "user_email" => @reg.user.email,
            }
          ] }
      end
    end
  end

  describe "POST upload_registrants" do
    before(:each) do
      @data = {"registrants" => []}
    end
    # set the included data as json
    let(:submit) { {:convert => {:data => @data.to_json} } }

    describe "with no data" do
      it "creates no models" do
        post :upload_registrants, submit
      end
    end
    describe "with a single registrant" do
      before(:each) do
        @data["registrants"] = [{"bib_number" => 1, "birthday" => "1982-05-19", "first_name" => "Bob", "last_name" => "Smith", "competitor" => true, "user_email" => "user@email.com"}]
      end
      it "creates the registrant" do
        expect {
          post :upload_registrants, submit
        }.to change(Registrant, :count).by(1)
        flash[:notice].should == "Created 1 records"
        r = Registrant.last
        r.birthday.should == Date.new(1982, 05, 19)
        r.first_name.should == "Bob"
        r.last_name.should == "Smith"
        r.competitor.should == true
        r.bib_number.should == 1
        r.user.email.should == "user@email.com"
      end
      it "doesn't create the Registrant if one already exists with that bib_number" do
        FactoryGirl.create(:registrant, :bib_number => 1)
        expect {
          post :upload_registrants, submit
        }.to change(Registrant, :count).by(0)
      end
    end
  end

  describe "GET download_time_results" do
    before(:each) do
      @ev = FactoryGirl.create(:event)
      @ec = @ev.event_categories.first
    end
    describe "with no data" do
      it "returns no entries for event" do
        get :download_time_results, {:event_category_id => @ec.id, :format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == { "time_results" => [] }
      end
    end
    describe "with a single time_result" do
      before(:each) do
        @reg = FactoryGirl.create(:competitor)
        @tr = FactoryGirl.create(:time_result, :event_category => @ec, :registrant => @reg, :minutes => 45, :seconds => 22, :thousands => 123, :disqualified => false)
      end
      it "returns the single time_result" do
        get :download_time_results, {:event_category_id => @ec.id, :format => 'json' }
        parsed_body = JSON.parse(response.body)
        parsed_body.should == {
          "time_results" => [
            { "bib_number" => 1,
              "minutes" => 45,
              "seconds" => 22,
              "thousands" => 123,
              "disqualified" => false
            }
          ] }
      end
    end
  end

  describe "POST upload_time_results" do
    before(:each) do
      @data = {"time_results" => []}
      @ev = FactoryGirl.create(:event)
      @ec = @ev.event_categories.first
      @reg = FactoryGirl.create(:competitor)
    end
    # set the included data as json
    let(:submit) { {:convert => {:event_category_id => @ec.id, :data => @data.to_json} } }

    describe "with no data" do
      it "creates no models" do
        post :upload_time_results, submit
      end
    end
    describe "with a single time_result" do
      before(:each) do
        @data["time_results"] = [{ "bib_number" => @reg.bib_number, "minutes" => 45, "seconds" => 22, "thousands" => 123, "disqualified" => false }]
      end
      it "creates the time_result" do
        expect {
          post :upload_time_results, submit
        }.to change(TimeResult, :count).by(1)
        flash[:notice].should == "Created 1 records"
        r = TimeResult.last
        r.registrant.bib_number.should == 1
        r.minutes.should == 45
        r.seconds.should == 22
        r.thousands.should == 123
        r.disqualified.should == false
      end
      it "can translate true strings" do
        @data["time_results"] = [{ "bib_number" => @reg.bib_number, "minutes" => 45, "seconds" => 22, "thousands" => 123, "disqualified" => "true" }]
        post :upload_time_results, submit
        r = TimeResult.last
        r.disqualified.should == true
      end

      it "can translate false string" do
        @data["time_results"] = [{ "bib_number" => @reg.bib_number, "minutes" => 45, "seconds" => 22, "thousands" => 123, "disqualified" => "false" }]
        post :upload_time_results, submit
        r = TimeResult.last
        r.disqualified.should == false
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
