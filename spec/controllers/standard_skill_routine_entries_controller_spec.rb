require 'spec_helper'

describe StandardSkillRoutineEntriesController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @ability = Ability.new(@user) 

    @registrant = FactoryGirl.create(:registrant, :user => @user)
    @routine = FactoryGirl.create(:standard_skill_routine, :registrant => @registrant)
    @initial_entry = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => @routine)
    new_skill = FactoryGirl.create(:standard_skill_entry)

    @valid_attributes = { standard_skill_routine_id: @routine.id,
                          standard_skill_entry_id: new_skill.id,
                          position: @initial_entry.position + 1}
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new StandardSkillRoutineEntry" do
        expect {
          post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => @valid_attributes}
        }.to change(StandardSkillRoutineEntry, :count).by(1)
      end

      it "assigns a newly created entry as @entry" do
        post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => @valid_attributes}
        assigns(:standard_skill_routine_entry).should be_a(StandardSkillRoutineEntry)
        assigns(:standard_skill_routine_entry).should be_persisted
      end

      it "redirects to the created entry" do
        post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => @valid_attributes}
        response.should redirect_to(standard_skill_routine_path(@routine))
      end
      describe "when 4 entries already exist" do
        before(:each) do
            5.times do |i|
                # creates 1b,2b,3b,4b
                skill = FactoryGirl.create(:standard_skill_entry)
                FactoryGirl.create(:standard_skill_routine_entry, 
                                   :standard_skill_routine => @routine,
                                   :standard_skill_entry => skill,
                                   :position => i+1)
            end
        end
        it "inserts a new element at the top of the list, by the 'position'" do
          # creates 5b
          skill = FactoryGirl.create(:standard_skill_entry)
          post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => { 
              standard_skill_routine_id: @routine.id,
              standard_skill_entry_id: skill.id,
              position: 1 }}
          response.should redirect_to(standard_skill_routine_path(@routine))
        end
        it "inserts a new one at the bottom of the list, if no position specified" do
          skill = FactoryGirl.create(:standard_skill_entry)
          post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => { 
              standard_skill_routine_id: @routine.id,
              standard_skill_entry_id: skill.id }}
          response.should redirect_to(standard_skill_routine_path(@routine))
          # 1 initial, + 5 + 1 == 7
          assigns(:standard_skill_routine_entry).position.should == 7
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved entry as @entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        StandardSkillRoutine.any_instance.stub(:save).and_return(false)
        post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => {:position => 1}}
        assigns(:standard_skill_routine_entry).should be_a_new(StandardSkillRoutineEntry)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        StandardSkillRoutine.any_instance.stub(:save).and_return(false)
        post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => {:position => 1}}
        response.should render_template("show")
      end
    end
    describe "when standard_skill is closed" do
      before(:each) do
        FactoryGirl.create(:event_configuration, :standard_skill_closed_date => Date.yesterday)
      end

      it "Cannot create new entries" do
        expect {
          post :create, {:standard_skill_routine_id => @routine.id, :standard_skill_routine_entry => @valid_attributes}
        }.to change(StandardSkillRoutineEntry, :count).by(0)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested entry" do
      entry = @initial_entry
      expect {
        delete :destroy, {:standard_skill_routine_id => @routine.id, :id => entry.to_param}
      }.to change(StandardSkillRoutineEntry, :count).by(-1)
    end

    it "redirects to the entries list" do
      entry = StandardSkillRoutineEntry.create! @valid_attributes
      delete :destroy, {:standard_skill_routine_id => @routine.id, :id => entry.to_param}
      response.should redirect_to(standard_skill_routine_path(@routine))
    end
    it "is unable to destroy another user's entry" do
      @other_entry = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => FactoryGirl.create(:standard_skill_routine))
      @ability.should_not be_able_to(:destroy, @other_entry)
    end
    it "is able to destroy own user's entry" do
      @ability.should be_able_to(:destroy, @initial_entry)
    end
  end
end
