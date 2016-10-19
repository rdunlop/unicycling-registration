# == Schema Information
#
# Table name: time_results
#
#  id                  :integer          not null, primary key
#  competitor_id       :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string(255)      not null
#  comments            :text
#  comments_by         :string(255)
#  number_of_penalties :integer
#  entered_at          :datetime         not null
#  entered_by_id       :integer          not null
#  preliminary         :boolean
#  heat_lane_result_id :integer
#  status_description  :string
#
# Indexes
#
#  index_time_results_on_competitor_id        (competitor_id)
#  index_time_results_on_heat_lane_result_id  (heat_lane_result_id) UNIQUE
#

require 'spec_helper'

describe TimeResultsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @competition = FactoryGirl.create(:competition)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
    @competition = @competitor.competition
  end

  # This should return the minimal set of attributes required to create a valid
  # EventCategory. As you add validations to EventCategory, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      status: "active",
      minutes: 0,
      seconds: 1,
      thousands: 2,
      competitor_id: @competitor.id
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read time_results" do
      get :index, params: { competition_id: @competition.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "shows all time_results" do
      time_result = FactoryGirl.create(:time_result, competitor: @competitor)
      get :index, params: { competition_id: @competition.id }

      assert_select "h1", "Listing Time Results for #{@competition}"
      assert_select "td", time_result.competitor.to_s
    end

    it "shows new time_result form" do
      get :index, params: { competition_id: @competition.id }

      assert_select "h2", "New Time Result"
    end
  end

  describe "GET edit" do
    it "shows the requested time_result form" do
      time_result = FactoryGirl.create(:time_result)
      get :edit, params: { id: time_result.id }

      assert_select "h1", "Editing Time Result"
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TimeResult" do
        expect do
          post :create, params: { competition_id: @competition.id, time_result: valid_attributes }
        end.to change(TimeResult, :count).by(1)
      end

      it "redirects to the created time_result" do
        post :create, params: { competition_id: @competition.id, time_result: valid_attributes }
        expect(response).to redirect_to(competition_time_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "does not create the time result" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        expect do
          post :create, params: { competition_id: @competition.id, time_result: {status: "DQ"} }
        end.not_to change(TimeResult, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        post :create, params: { competition_id: @competition.id, time_result: {status: "DQ"} }
        assert_select "h1", "Listing Time Results for #{@competition}"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "redirects to the event time results" do
        other_competitor = FactoryGirl.create(:event_competitor, competition: @competition)
        time_result = FactoryGirl.create(:time_result, competitor: other_competitor)
        put :update, params: { id: time_result.to_param, time_result: valid_attributes }
        expect(response).to redirect_to(competition_time_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "does not update the time_result" do
        time_result = FactoryGirl.create(:time_result)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: time_result.to_param, time_result: {status: "DQ"} }
        end.not_to change { time_result.reload.status }
      end

      it "re-renders the 'edit' template" do
        time_result = FactoryGirl.create(:time_result)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        put :update, params: { id: time_result.to_param, time_result: {status: "DQ"} }
        assert_select "h1", "Editing Time Result"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested time_result" do
      time_result = FactoryGirl.create(:time_result)
      expect do
        delete :destroy, params: { id: time_result.to_param }
      end.to change(TimeResult, :count).by(-1)
    end

    it "redirects to the event's time_results list" do
      time_result = FactoryGirl.create(:time_result)
      competition = time_result.competition
      delete :destroy, params: { id: time_result.to_param }
      expect(response).to redirect_to(competition_time_results_path(competition))
    end
  end
end
