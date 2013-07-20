require 'spec_helper'

describe DistanceAttemptsController do
  before(:each) do
    @judge_user = FactoryGirl.create(:judge_user)
    sign_in @judge_user
  end

  describe "GET 'index'" do
    describe "when a Competitor is assigned to the distance event" do
      let(:ev) { FactoryGirl.create(:distance_event) }
      let(:competition) { FactoryGirl.create(:competition, :event => ev) }
      let(:comp)  { FactoryGirl.create(:event_competitor, :competition => competition) }
      let(:judge) { FactoryGirl.create(:judge, :competition => competition) }
      it "returns http success" do
        da = FactoryGirl.create(:distance_attempt, :judge => judge, :competitor => comp)

        get 'index', {:judge_id => judge.id}

        response.should be_success
        assigns(:max_distance_attempts).should eq([da])
        assigns(:competition).should eq(competition)
      end
      it "returns the competitor when an external_id is specified" do

        get 'index', :judge_id => judge.id, :external_id => comp.external_id

        response.should redirect_to(new_judge_competitor_distance_attempt_path(judge, comp))
      end
      it "returns an error message if the external_id is not found" do

        get 'index', :judge_id => judge.id, :external_id => "100"

        flash[:alert].should == "Unable to find a Registrant with that ID (100)"
      end
      it "returns an error message if the registrant isn't registered for this event" do
        ev2 = FactoryGirl.create(:distance_event)
        competition2 =FactoryGirl.create(:competition, :event => ev2)
        judge = FactoryGirl.create(:judge, :competition => competition2)

        get 'index', :judge_id => judge.id, :external_id => comp.external_id

        flash[:alert].should == "That Registrant (#{comp.external_id}) is not registered for this event"
      end
      describe "looking at the 'index' for a specific competitor" do
        it "returns the correct objects when looking at a competitor index" do

          get 'new', :judge_id => judge.id, :competitor_id => comp.id

          response.should be_success
          assigns(:judge).should eq(judge)
          assigns(:competition).should eq(competition)
          assigns(:competitor).should eq(comp)
          assigns(:distance_attempt).should be_a_new(DistanceAttempt)
        end

        it "only returns the distance_attempts for this competitor" do
          da = FactoryGirl.create(:distance_attempt) # for a different event/competitor

          get 'index', :judge_id => judge.id, :competitor_id => comp.id

          assigns(:distance_attempts).should eq([])
        end

        it "only returns distance_attempts for this event" do
          ev  = FactoryGirl.create(:distance_event)
          ev2 = FactoryGirl.create(:distance_event)
          competition = FactoryGirl.create(:competition, :event => ev)
          competition2 = FactoryGirl.create(:competition, :event => ev2)

          comp  = FactoryGirl.create(:event_competitor, :competition => competition)
          comp2 = FactoryGirl.create(:event_competitor, :competition => competition2)
          judge = FactoryGirl.create(:judge, :competition => competition)

          da  = FactoryGirl.create(:distance_attempt, :competitor => comp)
          da2 = FactoryGirl.create(:distance_attempt, :competitor => comp2) # for a different event/competitor

          get 'index', :judge_id => judge.id

          assigns(:distance_attempts).should eq([da])
        end
      end
    end
  end
  describe "POST create" do
    before (:each) do
        @ev = FactoryGirl.create(:distance_event)
        @competition = FactoryGirl.create(:competition, :event => @ev)
        @comp = FactoryGirl.create(:event_competitor, :competition => @competition)
        @judge = FactoryGirl.create(:judge, :competition => @competition)
    end
    def valid_attributes
      {
          distance: 1.2,
          fault: false,
      }
    end
    describe "with valid params" do
      it "creates a new DistanceAttempt" do
        expect {
          post :create, {:distance_attempt => valid_attributes, :judge_id => @judge.id, :competitor_id => @comp.id}
        }.to change(DistanceAttempt, :count).by(1)

        response.should redirect_to(new_judge_competitor_distance_attempt_path(@judge, @comp))
      end
    end
    describe "with invalid params" do
        it "renders the 'new' form" do
           post :create, {:distance_attempt => {}, :judge_id => @judge.id, :competitor_id => @comp.id}
           response.should render_template("new")
        end
    end
  end

  describe "GET list" do
    before(:each) do
        @ev = FactoryGirl.create(:distance_event)
        @competition = FactoryGirl.create(:competition, :event => @ev)
        @comp = FactoryGirl.create(:event_competitor, :competition => @competition)
        @judge = FactoryGirl.create(:judge, :competition => @competition)
    end
    it "should return a list of all distance_attempts" do
        get :list, {:judge_id => @judge.id}

        response.should render_template("list")
    end
    it "should return the distance attempts" do
        da = FactoryGirl.create(:distance_attempt, :judge => @judge, :competitor => @comp)
        get :list, {:judge_id => @judge.id}

        assigns(:distance_attempts).should eq([da])
    end
    it "should not be accessible to non-judges" do
        sign_out @judge_user
        @normal_user = FactoryGirl.create(:user)
        sign_in @normal_user

        get :list, {:judge_id => @judge.id}

        response.should redirect_to(root_path)
    end
  end
end
