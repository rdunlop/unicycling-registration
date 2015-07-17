require 'spec_helper'

xdescribe StandardSkillRoutinesController do
  before (:each) do
    @user = FactoryGirl.create(:super_admin_user)
    @registrant = FactoryGirl.create(:competitor, user: @user)
    sign_in @user
  end

  describe "GET show" do
    it "assigns the requested routine as @standard_skill_routine" do
      routine = FactoryGirl.create(:standard_skill_routine, registrant: @registrant)
      get :show, id: routine.to_param
      expect(assigns(:standard_skill_routine)).to eq(routine)
      expect(assigns(:total)).to eq(0)
      expect(assigns(:entry)).to be_a_new(StandardSkillRoutineEntry)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new routine" do
        expect do
          post :create, registrant_id: @registrant.id
        end.to change(StandardSkillRoutine, :count).by(1)
      end

      it "redirects to the created routine" do
        post :create, registrant_id: @registrant.id
        expect(response).to redirect_to(StandardSkillRoutine.last)
      end
    end

    it "Cannot create a routine for another user" do
      post :create, registrant_id: FactoryGirl.create(:registrant).id
      expect(response).to redirect_to(root_path)
    end

    describe "when standard skill is closde" do
      before(:each) do
        FactoryGirl.create(:event_configuration, standard_skill_closed_date: Date.yesterday)
      end

      it "cannot create a new routine" do
        post :create, registrant_id: @registrant.id
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "as super_admin" do
    before (:each) do
      sign_out @user
      @super_admin_user = FactoryGirl.create(:super_admin_user)
      sign_in @super_admin_user
    end

    describe "GET download_file" do
      before(:each) do
        @initial_entry = FactoryGirl.create(:standard_skill_routine_entry)
        @next_entry = FactoryGirl.create(:standard_skill_routine_entry)
      end
      it "downloads the standard_skill_routine_entries for everyone" do
        get :download_file
        csv = CSV.parse(response.body, headers: true)

        expect(csv.count).to eq(2)

        row1 = csv[0]
        expect(row1.count).to eq(4)
        expect(row1[0]).to eq(@initial_entry.standard_skill_routine.registrant.external_id.to_s)
        expect(row1[1]).to eq(@initial_entry.position.to_s)
        expect(row1[2]).to eq(@initial_entry.standard_skill_entry.number.to_s)
        expect(row1[3]).to eq(@initial_entry.standard_skill_entry.letter.to_s)

        row2 = csv[1]
        expect(row2.count).to eq(4)
        expect(row2[0]).to eq(@next_entry.standard_skill_routine.registrant.external_id.to_s)
        expect(row2[1]).to eq(@next_entry.position.to_s)
        expect(row2[2]).to eq(@next_entry.standard_skill_entry.number.to_s)
        expect(row2[3]).to eq(@next_entry.standard_skill_entry.letter.to_s)
      end

      it "should fail for non-admin user" do
        @user = FactoryGirl.create(:user)
        sign_in @user

        get :download_file

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
