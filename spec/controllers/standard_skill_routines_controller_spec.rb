require 'spec_helper'

describe StandardSkillRoutinesController do
  before (:each) do
    @user = FactoryGirl.create(:user)
    @registrant = FactoryGirl.create(:competitor, :user => @user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Registrant. As you add validations to Registrant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      }
  end

  describe "GET show" do
    it "assigns the requested routine as @standard_skill_routine" do
      routine = FactoryGirl.create(:standard_skill_routine, :registrant => @registrant)
      get :show, {:id => routine.to_param}
      assigns(:standard_skill_routine).should eq(routine)
      assigns(:total).should == 0
      assigns(:entry).should be_a_new(StandardSkillRoutineEntry)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new routine" do
        expect {
          post :create, {:registrant_id => @registrant.id}
        }.to change(StandardSkillRoutine, :count).by(1)
      end

      it "redirects to the created routine" do
        post :create, {:registrant_id => @registrant.id}
        response.should redirect_to(StandardSkillRoutine.last)
      end
    end

    it "Cannot create a routine for another user" do
      post :create, {:registrant_id => FactoryGirl.create(:registrant).id}
      response.should redirect_to(root_path)
    end
  end
end
