require 'spec_helper'

describe ExportController do
  before do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end

  describe "GET download_competitors_for_timers" do
    before do
      EventConfiguration.singleton.update(short_name: "this is the event")
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
      before do
        @ev = FactoryBot.create(:event)
      end

      it "lists the event titles" do
        get :download_events, format: 'xls'
        assert_equal "application/vnd.ms-excel", @response.content_type
      end
    end
  end

  describe "GET results" do
    let!(:result) { FactoryBot.create(:result, :overall) }

    it "returns much data" do
      get :results, format: 'xls'
      assert_equal "application/vnd.ms-excel", @response.content_type
    end
  end

  describe "GET download_payment_details" do
    let(:expense_item) { FactoryBot.create(:expense_item) }

    it "returns much data" do
      get :download_payment_details, format: 'xls', params: { data: { expense_item_id: expense_item.id } }
      assert_equal "application/vnd.ms-excel", @response.content_type
    end
  end

  describe "GET download_payment_details_by_category" do
    let(:expense_item) { FactoryBot.create(:expense_item) }

    it "returns much data" do
      get :download_payment_details_by_category, format: 'xls', params: { data: { expense_group_id: expense_item.expense_group.id } }
      assert_equal "application/vnd.ms-excel", @response.content_type
    end
  end
end
