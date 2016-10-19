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
    it "without any events or registrants, only prints the headers" do
      get :download_events, format: 'xls'
      assert_equal "application/vnd.ms-excel", @response.content_type
    end

    describe "with some events defined" do
      before(:each) do
        @ev = FactoryGirl.create(:event)
      end

      it "lists the event titles" do
        get :download_events, format: 'xls'
        assert_equal "application/vnd.ms-excel", @response.content_type
      end
    end
  end

  describe "GET results" do
    let!(:result) { FactoryGirl.create(:result, :overall) }

    it "returns much data" do
      get :results, format: 'xls'
      assert_equal "application/vnd.ms-excel", @response.content_type
    end
  end

  describe "GET download_payment_details" do
    let(:expense_item) { FactoryGirl.create(:expense_item) }
    it "returns much data" do
      get :download_payment_details, format: 'xls', params: { data: { expense_item_id: expense_item.id } }
      assert_equal "application/vnd.ms-excel", @response.content_type
    end
  end
end
