require 'spec_helper'

describe JudgesController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @super_admin = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:competition, event: @ev)
    @data_entry_volunteer_user = FactoryGirl.create(:data_entry_volunteer_user)
    @judge_type = FactoryGirl.create(:judge_type, event_class: @ec.event_class)
    @other_judge_type = FactoryGirl.create(:judge_type, event_class: "Flatland")
  end

  # This should return the minimal set of attributes required to create a valid
  # EventsJudgeType. As you add validations to EventsJudgeType, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { judge_type_id: 1,
      user_id: @user.id }
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventJudgeType" do
        expect do
          post :create, judge: valid_attributes, competition_id: @ec.id
        end.to change(Judge, :count).by(1)
      end

      it "assigns a newly created judge as @judge" do
        post :create, judge: valid_attributes, competition_id: @ec.id
        expect(assigns(:judge)).to be_a(Judge)
        expect(assigns(:judge)).to be_persisted
      end

      it "redirects to the events show page" do
        post :create, judge: valid_attributes, competition_id: @ec.id
        expect(response).to redirect_to(competition_judges_path(@ec))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved judge as @judge" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Judge).to receive(:valid?).and_return(false)
        allow_any_instance_of(Judge).to receive(:errors).and_return("something")
        post :create, judge: {user_id: 1}, competition_id: @ec.id
        expect(assigns(:judge)).to be_a_new(Judge)
        expect(assigns(:judge_types)).to eq([@judge_type])
        expect(assigns(:all_data_entry_volunteers)).to eq([@data_entry_volunteer_user])
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Judge).to receive(:valid?).and_return(false)
        allow_any_instance_of(Judge).to receive(:errors).and_return("something")
        post :create, judge: {user_id: 1}, competition_id: @ec.id
        expect(response).to render_template("index")
      end
    end
  end

  describe "POST copy_judges" do
    it "copies judges from event to event" do
      @new_competition = FactoryGirl.create(:competition)
      FactoryGirl.create(:judge, competition: @new_competition)

      expect(@ec.judges.count).to eq(0)

      post :copy_judges, competition_id: @ec.id, copy_judges: {competition_id: @new_competition.id}

      expect(@ec.judges.count).to eq(1)
    end
    it "should fail when not an admin" do
      sign_out @super_admin
      sign_in @user

      @new_competition = FactoryGirl.create(:competition)
      FactoryGirl.create(:judge, competition: @new_competition)

      expect(@ec.judges.count).to eq(0)

      post :copy_judges, competition_id: @ec.id, copy_judges: {competition_id: @new_competition }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested judge" do
      judge = FactoryGirl.create(:judge, competition: @ec)
      expect do
        delete :destroy, id: judge.to_param, competition_id: @ec.id
      end.to change(Judge, :count).by(-1)
    end

    it "redirects to the judges list" do
      judge = FactoryGirl.create(:judge, competition: @ec)
      delete :destroy, id: judge.to_param, competition_id: @ec.id
      expect(response).to redirect_to(competition_judges_path(@ec))
    end
  end

  describe "GET index" do
    it "displays all of the judges for all" do
      get :index, competition_id: @ec
      expect(assigns(:all_data_entry_volunteers)).to eq([@data_entry_volunteer_user])
    end

    it "lists this events' judges" do
      other_data_entry_volunteer_user = FactoryGirl.create(:user)
      other_data_entry_volunteer_user.add_role(:data_entry_volunteer)
      @judge = FactoryGirl.create(:judge, user: @data_entry_volunteer_user, competition: @ec)
      get :index, competition_id: @ec
      expect(assigns(:judges)).to include(@judge)
    end

    it "has a blank judge" do
      get :index, competition_id: @ec
      expect(assigns(:judge)).to be_a_new(Judge)
    end
  end
end
