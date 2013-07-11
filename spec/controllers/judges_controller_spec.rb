require 'spec_helper'

describe JudgesController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @super_admin = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
    @judge_user = FactoryGirl.create(:judge_user)
    @judge_type = FactoryGirl.create(:judge_type, :event_class => @ev.event_class)
    @other_judge_type = FactoryGirl.create(:judge_type, :event_class => "Flatland")
  end

  # This should return the minimal set of attributes required to create a valid
  # EventsJudgeType. As you add validations to EventsJudgeType, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { judge_type_id: 1,
      user_id: @user.id }
  end
  
  describe "GET new" do
    it "assigns the judge types" do
        get :new, {:event_category_id => @ec.id }

        assigns(:judge_types).should == [@judge_type]
        assigns(:all_judges).should == [@judge_user]
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventJudgeType" do
        expect {
          post :create, {:judge => valid_attributes, :event_category_id => @ec.id}
        }.to change(Judge, :count).by(1)
      end

      it "assigns a newly created judge as @judge" do
        post :create, {:judge => valid_attributes, :event_category_id => @ec.id}
        assigns(:judge).should be_a(Judge)
        assigns(:judge).should be_persisted
      end

      it "redirects to the events show page" do
        post :create, {:judge => valid_attributes, :event_category_id => @ec.id}
        response.should redirect_to(new_event_category_judge_path(@ec))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved judge as @judge" do
        # Trigger the behavior that occurs when invalid params are submitted
        Judge.any_instance.stub(:save).and_return(false)
        post :create, {:judge => {}, :event_category_id => @ec.id}
        assigns(:judge).should be_a_new(Judge)
        assigns(:judge_types).should == [@judge_type]
        assigns(:all_judges).should == [@judge_user]
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Judge.any_instance.stub(:save).and_return(false)
        post :create, {:judge => {}, :event_category_id => @ec.id}
        response.should render_template("new")
      end
    end
  end

  describe "POST copy_judges" do
    it "copies judges from event to event" do
        @new_event = FactoryGirl.create(:event)
        judge = FactoryGirl.create(:judge, :event_category => @new_event.event_categories.first)

        @ec.judges.count.should == 0

        post :copy_judges, {:event_category_id => @ec.id, :copy_judges => {:event_category_id => @new_event.event_categories.first.id}}

        @ec.judges.count.should == 1
    end
    it "should fail when not an admin" do
      sign_out @super_admin
      sign_in @user

      @new_event = FactoryGirl.create(:event)
      judge = FactoryGirl.create(:judge, :event_category => @new_event.event_categories.first)

      @ec.judges.count.should == 0

      post :copy_judges, {:event_category_id => @ec.id, :copy_judges => {:event_category_id => @new_event.event_categories.first.id}}
      response.should redirect_to(root_path)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested judge" do
      judge = FactoryGirl.create(:judge, :event_category => @ec)
      expect {
        delete :destroy, {:id => judge.to_param, :event_category_id => @ec.id}
      }.to change(Judge, :count).by(-1)
    end

    it "redirects to the judges list" do
      judge = FactoryGirl.create(:judge, :event_category => @ec)
      delete :destroy, {:id => judge.to_param, :event_category_id => @ec.id}
      response.should redirect_to(new_event_category_judge_path(@ec))
    end
  end

end
