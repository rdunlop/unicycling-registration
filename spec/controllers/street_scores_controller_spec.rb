require 'spec_helper'

describe StreetScoresController do
  before (:each) do
    @admin = FactoryGirl.create(:admin_user)
    @user = FactoryGirl.create(:data_entry_volunteer_user)
    @other_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @admin

    @judge = FactoryGirl.create(:judge, user_id: @user.id)
    @other_judge = FactoryGirl.create(:judge, user_id: @other_user.id)

    @comp = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @comp2 = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @judge.competition.competitors << @comp2
    @judge.competition.competitors << @comp
    @judge.save!

    sign_out @admin

    # create a chief_judge, so that this lowly judge-user can see the scores page
    @user.add_role :director, @judge.event

    sign_in @user
  end

  describe "GET index" do
    it "assigns all scores as @scores" do
      get :index, {judge_id: @judge.id}
      expect(response).to be_success
    end
    describe "when returning a list of scores" do
      before(:each) do
        @user_score1 = FactoryGirl.create(:score, val_1: 5, judge: @judge, competitor: @comp)
        @user_score2 = FactoryGirl.create(:score, val_1: 6, judge: @judge, competitor: @comp2)
      end

      it "should return them in descending order of val_1 points" do
        get :index, {judge_id: @judge.id}
        expect(assigns(:street_scores)).to eq([@user_score2, @user_score1])
      end
    end
  end

  describe "POST create" do
    describe "with valid competitor_id" do
      it "creates a new Score" do
        expect do
          post :update_score, {competitor_id: @comp2.id, score: 4, judge_id: @judge.id, format: :js}
        end.to change(Score, :count).by(1)
      end
    end
  end
  describe "DELETE destroy" do
    before(:each) do
      @user_score1 = FactoryGirl.create(:score, val_1: 5, judge: @judge, competitor: @comp)
      @user_score2 = FactoryGirl.create(:score, val_1: 6, judge: @judge, competitor: @comp2)
    end
    it "should allow access to destroy" do
      expect do
        delete :destroy, {id: @user_score1.to_param, judge_id: @judge.id}
      end.to change(Score, :count).by(-1)
    end
  end

  describe "authentication of edit/update pages" do
    # http://ruby.railstutorial.org/chapters/updating-showing-and-deleting-users#sec:protecting_pages

    before (:each) do
      # create score with existing current_user
      @user_score = FactoryGirl.create(:score, judge: @judge, competitor: @comp)

      # Change logged-in user
      sign_out @user
      @auth_user = FactoryGirl.create(:user)
      sign_in @auth_user
    end
    it "should deny access to index" do
      get :index, {judge_id: @judge}
      expect(response).to redirect_to(root_path)
    end
    it "should deny access to destroy" do
      delete :destroy, {id: @user_score.to_param, judge_id: @judge}
      expect(response).to redirect_to(root_path)
    end
  end
end
