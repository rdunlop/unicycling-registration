require 'spec_helper'

describe DataEntryVolunteersController do
  before do
    @user = FactoryBot.create(:user)
    @super_admin = FactoryBot.create(:super_admin_user)
    sign_in @super_admin
    @ev = FactoryBot.create(:event)
    @ec = FactoryBot.create(:competition, event: @ev)
    @data_entry_volunteer_user = FactoryBot.create(:data_entry_volunteer_user)
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
        expect do
          post :create, params: { data_entry_volunteer: { user_id: @user.id, name: "Robin" }, competition_id: @ec.id }
        end.to change(@user.roles, :count).by(1)
      end

      it "updates the user's name" do
        post :create, params: { data_entry_volunteer: { user_id: @user.id, name: "Robin" }, competition_id: @ec.id }
        expect(@user.reload.to_s).to eq("Robin")
      end
    end

    it "fails when not an admin" do
      sign_out @super_admin
      sign_in @user

      post :create, params: { data_entry_volunteer: { user_id: @user.id, name: "Robin" }, competition_id: @ec.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "missing a name" do
    it "doesn't create the volunteer" do
      expect do
        post :create, params: { data_entry_volunteer: { user_id: @user.id, name: "" }, competition_id: @ec.id }
      end.not_to change(@user.roles, :count)
    end
  end
end
