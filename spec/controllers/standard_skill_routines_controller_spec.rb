# == Schema Information
#
# Table name: standard_skill_routines
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_standard_skill_routines_on_registrant_id  (registrant_id) UNIQUE
#

require 'spec_helper'

describe StandardSkillRoutinesController do
  before do
    EventConfiguration.singleton.update(standard_skill: true, standard_skill_closed_date: 1.week.from_now)
    @user = FactoryBot.create(:user)
    @registrant = FactoryBot.create(:competitor, user: @user)
    sign_in @user
  end

  describe "GET show" do
    it "shows the requested routine" do
      routine = FactoryBot.create(:standard_skill_routine, registrant: @registrant)
      FactoryBot.create(:standard_skill_routine_entry, standard_skill_routine: routine, standard_skill_entry: FactoryBot.create(:standard_skill_entry, number: 1, letter: "a", description: "One"))
      get :show, params: { id: routine.to_param }

      assert_match(/One/, response.body)

      assert_select "form", action: standard_skill_routine_standard_skill_routine_entries_path(routine), method: "post" do
        assert_select "select#standard_skill_routine_entry_standard_skill_entry_id", name: "standard_skill_routine_entry[standard_skill_entry_id]"
        assert_select "input#standard_skill_routine_entry_position", name: "standard_skill_routine_entry[position]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new routine" do
        expect do
          post :create, params: { registrant_id: @registrant.to_param }
        end.to change(StandardSkillRoutine, :count).by(1)
      end

      it "redirects to the created routine" do
        post :create, params: { registrant_id: @registrant.to_param }
        expect(response).to redirect_to(StandardSkillRoutine.last)
      end
    end

    describe "when a routine already exists" do
      let!(:standard_skill_routine) { FactoryBot.create(:standard_skill_routine, registrant: @registrant) }

      it "redirects to that routine without creating a new one" do
        expect do
          post :create, params: { registrant_id: @registrant.to_param }
        end.not_to change(StandardSkillRoutine, :count)
        expect(response).to redirect_to(standard_skill_routine)
      end
    end

    it "Cannot create a routine for another user" do
      post :create, params: { registrant_id: FactoryBot.create(:registrant).to_param }
      expect(response).to redirect_to(root_path)
    end

    describe "when standard skill is closed" do
      before do
        EventConfiguration.singleton.update_attribute(:standard_skill_closed_date, Date.yesterday)
      end

      it "cannot create a new routine" do
        post :create, params: { registrant_id: @registrant.to_param }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
