require 'spec_helper'

describe DataEntryVolunteersController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @super_admin = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:competition, :event => @ev)
    @data_entry_volunteer_user = FactoryGirl.create(:data_entry_volunteer_user)
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
      it "creates a new Volunteer" do
        expect {
          post :create, {:data_entry_volunteer => {user_id: @user.id, name: "Robin"}, :competition_id => @ec.id}
        }.to change(@user.roles, :count).by(1)
      end

      it "updates the user's name" do
        post :create, {:data_entry_volunteer => {user_id: @user.id, name: "Robin"}, :competition_id => @ec.id}
        expect(@user.reload.to_s).to eq("Robin")
      end
    end

    it "should fail when not an admin" do
      sign_out @super_admin
      sign_in @user

      post :create, {:data_entry_volunteer => {user_id: @user.id, name: "Robin"}, :competition_id => @ec.id}
      response.should redirect_to(root_path)
    end
  end

  describe "missing a name" do
    it "doesn't create the volunteer" do
      expect {
        post :create, { data_entry_volunteer: {user_id: @user.id, name: ""}, competition_id: @ec.id }
      }.to_not change(@user.roles, :count)
    end
  end
end
