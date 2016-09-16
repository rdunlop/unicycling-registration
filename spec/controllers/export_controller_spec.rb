require 'spec_helper'

describe ExportController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET download_competitors_for_timers" do
    before do
      FactoryGirl.create(:event_configuration, short_name: "this is the event")
    end

    it "can download the file" do
      get :download_competitors_for_timers
      expect(response).to be_success
    end
  end

  describe "GET download_events" do
    let(:base_headers) { ["ID", "First Name", "Last Name", "Birthday", "Age", "Gender", "Club"]}
    it "without any events or registrants, only prints the headers" do
      get :download_events, format: 'xls'
      expect(assigns(:headers)).to eq(base_headers)
    end
    describe "with some events defined" do
      before(:each) do
        @ev = FactoryGirl.create(:event)
      end
      it "lists the event titles" do
        get :download_events, format: 'xls'
        headers = assigns(:headers)
        expect(headers).to eq(base_headers << @ev.event_categories.first.to_s)
      end
      it "lists the each event_choice separately, with event-prefixed" do
        get :download_events, format: 'xls'
        ec = EventCategory.all.first
        headers = assigns(:headers)
        expect(headers).to eq(base_headers << ec.to_s)
      end

      describe "with a competitor" do
        before(:each) do
          @reg = FactoryGirl.create(:competitor)
        end
        it "has a row for that competitor" do
          get :download_events, format: 'xls'
          data = assigns(:data)
          expect(data[0]).to eq([@reg.bib_number, @reg.first_name, @reg.last_name, @reg.birthday, @reg.age, @reg.gender, @reg.club, nil])
        end
        describe "with a registration choice for the event" do
          before(:each) do
            @ecat = @ev.event_categories.first
            @rc = FactoryGirl.create(:registrant_event_sign_up, registrant: @reg, event_category: @ecat, event: @ev, signed_up: true)
          end

          it "has a value in the event-signed-up target column" do
            get :download_events, format: 'xls'
            data = assigns(:data)
            expect(data[0][base_headers.count]).to eq(true)
          end
        end
      end
    end
  end

  describe "GET results" do
    let!(:result) { FactoryGirl.create(:result, :overall) }

    it "returns much data" do
      get :results, format: 'xls'
      data = assigns(:data)
      expect(data.count).to eq(1)
    end
  end
end
