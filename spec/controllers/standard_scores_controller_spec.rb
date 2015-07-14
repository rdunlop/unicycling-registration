require 'spec_helper'

xdescribe StandardScoresController do
  before (:each) do
    @admin = FactoryGirl.create(:super_admin_user)
    @user = FactoryGirl.create(:data_entry_volunteer_user)
    @other_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @admin

    @judge = FactoryGirl.create(:judge, user_id: @user.id)

    @comp = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @comp2 = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @judge.competition.competitors << @comp2
    @judge.competition.competitors << @comp
    @judge.save!
  end

  # This should return the minimal set of attributes required to create a valid
  # Score. As you add validations to Score, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { }
  end

  describe "GET index" do
    it "assigns all competitors as @competitors" do
      get :index, judge_id: @judge.id
      expect(response).to be_success
      expect(assigns(:competitors)).to eq([@comp, @comp2])
    end
  end

  describe "GET new" do
    it "assigns the associated skills_routines as @skills" do
      FactoryGirl.create(:standard_execution_score, judge: @judge, competitor: @comp)
      @routine = FactoryGirl.create(:standard_skill_routine, registrant: @comp.registrants.first)
      skill = FactoryGirl.create(:standard_skill_routine_entry, standard_skill_routine: @routine)

      get :new, judge_id: @judge.id, competitor_id: @comp.id
      expect(assigns(:skills)).to eq([skill])
    end
  end
end
