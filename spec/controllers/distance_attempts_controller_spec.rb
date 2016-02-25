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
  let(:comp) { FactoryGirl.create(:event_competitor, competition: competition) }
  before(:each) do
    @data_entry_volunteer_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @data_entry_volunteer_user
  end

  describe "POST create" do
    before (:each) do
      @judge = FactoryGirl.create(:judge, competition: competition, user: @data_entry_volunteer_user)
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
          post :create, distance_attempt: valid_attributes, judge_id: @judge.id
        end.to change(DistanceAttempt, :count).by(1)

        expect(response).to redirect_to(judge_distance_attempts_path(@judge))
      end
    end
    describe "with invalid params" do
      it "renders the 'new' form" do
        post :create, distance_attempt: {fault: false}, judge_id: @judge.id
        expect(response).to render_template("index")
      end
    end
  end

  describe "GET list" do
    before(:each) do
      @judge = FactoryGirl.create(:judge, competition: competition, user: @data_entry_volunteer_user)
    end
    it "should return a list of all distance_attempts" do
      get :list, competition_id: competition.id

      expect(response).to render_template("list")
    end
    it "should return the distance attempts" do
      da = FactoryGirl.create(:distance_attempt, judge: @judge, competitor: comp)
      get :list, competition_id: competition.id

      expect(assigns(:distance_attempts)).to eq([da])
    end
    it "should not be accessible to non-data_entry_volunteers" do
      sign_out @data_entry_volunteer_user
      @normal_user = FactoryGirl.create(:user)
      sign_in @normal_user

      get :list, competition_id: competition.id

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
        delete :destroy, id: distance_attempt.to_param
      end.to change(DistanceAttempt, :count).by(-1)
    end

    it "redirects to the external_results list" do
      distance_attempt = FactoryGirl.create(:distance_attempt, competitor: comp)
      delete :destroy, id: distance_attempt.to_param
      expect(response).to redirect_to(root_path)
    end
  end
end
