require 'spec_helper'

describe StandardScoresController do
  before (:each) do
    @admin = FactoryGirl.create(:admin_user)
    @user = FactoryGirl.create(:judge_user)
    @other_user = FactoryGirl.create(:judge_user)
    sign_in @admin

    @judge = FactoryGirl.create(:judge, :user_id => @user.id)

    @comp = FactoryGirl.create(:event_competitor, :event_category => @judge.event_category)
    @comp2 = FactoryGirl.create(:event_competitor, :event_category => @judge.event_category)
    @judge.event_category.competitors << @comp2
    @judge.event_category.competitors << @comp
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
      get :index, {:judge_id => @judge.id}
      response.should be_success
      assigns(:competitors).should eq([@comp, @comp2])
    end
  end

  describe "GET new" do
    it "assigns the associated skills_routines as @skills" do
      score = FactoryGirl.create(:standard_execution_score, :judge => @judge, :competitor => @comp)
      @routine = FactoryGirl.create(:standard_skill_routine, :registrant => @comp.registrants.first)
      skill = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => @routine)

      get :new, {:judge_id => @judge.id, :competitor_id => @comp.id}
      assigns(:skills).should eq([skill])
    end
  end
end
