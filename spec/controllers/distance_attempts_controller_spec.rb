require 'spec_helper'

describe DistanceAttemptsController do
  before(:each) do
    @data_entry_volunteer_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @data_entry_volunteer_user
  end

  describe "POST create" do
    before (:each) do
      @competition = FactoryGirl.create(:distance_competition)
      @comp = FactoryGirl.create(:event_competitor, :competition => @competition)
      @judge = FactoryGirl.create(:judge, :competition => @competition)
    end
    def valid_attributes
      {
        registrant_id: @comp.members.first.registrant.id,
        distance: 1.2,
        fault: false,
      }
    end
    describe "with valid params" do
      it "creates a new DistanceAttempt" do
        request.env["HTTP_REFERER"] = judge_distance_attempts_path(@judge)

        expect {
          post :create, {:distance_attempt => valid_attributes, :judge_id => @judge.id}
        }.to change(DistanceAttempt, :count).by(1)

        response.should redirect_to(judge_distance_attempts_path(@judge))
      end
    end
    describe "with invalid params" do
      it "renders the 'new' form" do
        post :create, {:distance_attempt => {:fault => false}, :judge_id => @judge.id}
        response.should render_template("index")
      end
    end
  end

  describe "GET list" do
    before(:each) do
      @competition = FactoryGirl.create(:distance_competition)
      @comp = FactoryGirl.create(:event_competitor, :competition => @competition)
      @judge = FactoryGirl.create(:judge, :competition => @competition)
    end
    it "should return a list of all distance_attempts" do
      get :list, {:competition_id => @competition.id}

      response.should render_template("list")
    end
    it "should return the distance attempts" do
      da = FactoryGirl.create(:distance_attempt, :judge => @judge, :competitor => @comp)
      get :list, {:competition_id => @competition.id}

      assigns(:distance_attempts).should eq([da])
    end
    it "should not be accessible to non-data_entry_volunteers" do
      sign_out @data_entry_volunteer_user
      @normal_user = FactoryGirl.create(:user)
      sign_in @normal_user

      get :list, {:competition_id => @competition.id}

      response.should redirect_to(root_path)
    end
  end
end
