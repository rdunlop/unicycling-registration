# == Schema Information
#
# Table name: distance_attempts
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  distance      :decimal(4, )
#  fault         :boolean          default(FALSE), not null
#  judge_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_distance_attempts_competitor_id  (competitor_id)
#  index_distance_attempts_judge_id       (judge_id)
#

require 'spec_helper'

describe DistanceAttemptsController do
  let(:competition) { FactoryGirl.create(:distance_competition) }
  let(:judge_type) { FactoryGirl.create(:judge_type, event_class: "High/Long")}
  let(:comp) { FactoryGirl.create(:event_competitor, competition: competition) }
  before do
    @data_entry_volunteer_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @data_entry_volunteer_user
  end

  describe "GET index" do
    before do
      @judge = FactoryGirl.create(:judge, competition: competition, user: @data_entry_volunteer_user, judge_type: judge_type)
    end

    it "should return a list of all distance_attempts" do
      get :index, params: { judge_id: @judge.id }

      assert_select "form", action: judge_distance_attempts_path(@judge), method: "get" do
        assert_select "input#distance_attempt_distance", name: "distance_attempt_distance"
      end
    end
  end

  describe "POST create" do
    before do
      @judge = FactoryGirl.create(:judge, competition: competition, user: @data_entry_volunteer_user, judge_type: judge_type)
    end
    def valid_attributes
      {
        registrant_id: comp.members.first.registrant.id,
        distance: 1.2,
        fault: false
      }
    end
    describe "with valid params" do
      it "creates a new DistanceAttempt" do
        request.env["HTTP_REFERER"] = judge_distance_attempts_path(@judge)

        expect do
          post :create, params: { distance_attempt: valid_attributes, judge_id: @judge.id }
        end.to change(DistanceAttempt, :count).by(1)

        expect(response).to redirect_to(judge_distance_attempts_path(@judge))
      end
    end
    describe "with invalid params" do
      it "renders the 'new' form" do
        post :create, params: { distance_attempt: {fault: false}, judge_id: @judge.id }
        assert_select "h1", "#{competition} - Distance Attempt"
      end
    end
  end

  describe "GET list" do
    before do
      @judge = FactoryGirl.create(:judge, competition: competition, user: @data_entry_volunteer_user, judge_type: judge_type)
    end

    it "should return the distance attempts" do
      da = FactoryGirl.create(:distance_attempt, judge: @judge, competitor: comp)
      get :list, params: { competition_id: competition.id }

      assert_select "td", da.competitor.to_s
    end
    it "should not be accessible to non-data_entry_volunteers" do
      sign_out @data_entry_volunteer_user
      @normal_user = FactoryGirl.create(:user)
      sign_in @normal_user

      get :list, params: { competition_id: competition.id }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE destroy" do
    before do
      request.env["HTTP_REFERER"] = root_path
    end

    it "destroys the requested distance_attempt" do
      distance_attempt = FactoryGirl.create(:distance_attempt, competitor: comp)
      expect do
        delete :destroy, params: { id: distance_attempt.to_param }
      end.to change(DistanceAttempt, :count).by(-1)
    end

    it "redirects to the external_results list" do
      distance_attempt = FactoryGirl.create(:distance_attempt, competitor: comp)
      delete :destroy, params: { id: distance_attempt.to_param }
      expect(response).to redirect_to(root_path)
    end
  end
end
