# == Schema Information
#
# Table name: standard_skill_routine_entries
#
#  id                        :integer          not null, primary key
#  standard_skill_routine_id :integer
#  standard_skill_entry_id   :integer
#  position                  :integer
#  created_at                :datetime
#  updated_at                :datetime
#

require 'spec_helper'

describe StandardSkillRoutineEntriesController do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
    @registrant = FactoryBot.create(:registrant, user: @user)
    @routine = FactoryBot.create(:standard_skill_routine, registrant: @registrant)
    @initial_entry = FactoryBot.create(:standard_skill_routine_entry, standard_skill_routine: @routine)
    new_skill = FactoryBot.create(:standard_skill_entry)

    @valid_attributes = { standard_skill_routine_id: @routine.id,
                          standard_skill_entry_id: new_skill.id,
                          position: @initial_entry.position + 1 }
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new StandardSkillRoutineEntry" do
        expect do
          post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: @valid_attributes }
        end.to change(StandardSkillRoutineEntry, :count).by(1)
      end

      it "redirects to the created entry" do
        post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: @valid_attributes }
        expect(response).to redirect_to(standard_skill_routine_path(@routine))
      end

      describe "when 4 entries already exist" do
        before do
          5.times do |i|
            # creates 1b,2b,3b,4b
            skill = FactoryBot.create(:standard_skill_entry)
            FactoryBot.create(:standard_skill_routine_entry,
                              standard_skill_routine: @routine,
                              standard_skill_entry: skill,
                              position: i + 1)
          end
        end

        it "inserts a new element at the top of the list, by the 'position'" do
          # creates 5b
          skill = FactoryBot.create(:standard_skill_entry)
          post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: {
            standard_skill_routine_id: @routine.id,
            standard_skill_entry_id: skill.id,
            position: 1
          } }
          expect(response).to redirect_to(standard_skill_routine_path(@routine))
        end

        it "inserts a new one at the bottom of the list, if no position specified" do
          skill = FactoryBot.create(:standard_skill_entry)
          post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: {
            standard_skill_routine_id: @routine.id,
            standard_skill_entry_id: skill.id
          } }
          expect(response).to redirect_to(standard_skill_routine_path(@routine))
          # 1 initial, + 5 + 1 == 7
          expect(StandardSkillRoutineEntry.last.position).to eq(7)
        end
      end
    end

    describe "with invalid params" do
      it "does not create a new entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(StandardSkillRoutine).to receive(:save).and_return(false)
        expect do
          post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: { position: 1 } }
        end.not_to change(StandardSkillRoutineEntry, :count)
      end

      it "re-renders the 'show' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(StandardSkillRoutine).to receive(:save).and_return(false)
        post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: { position: 1 } }
        assert_select "h1", "#{@registrant} - Standard Skill Routine"
      end
    end

    describe "when standard_skill is closed" do
      before do
        EventConfiguration.singleton.update(standard_skill_closed_date: Date.yesterday)
      end

      it "Cannot create new entries" do
        expect do
          post :create, params: { standard_skill_routine_id: @routine.id, standard_skill_routine_entry: @valid_attributes }
        end.to change(StandardSkillRoutineEntry, :count).by(0)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested entry" do
      entry = @initial_entry
      expect do
        delete :destroy, params: { standard_skill_routine_id: @routine.id, id: entry.to_param }
      end.to change(StandardSkillRoutineEntry, :count).by(-1)
    end

    it "redirects to the entries list" do
      entry = StandardSkillRoutineEntry.create! @valid_attributes
      delete :destroy, params: { standard_skill_routine_id: @routine.id, id: entry.to_param }
      expect(response).to redirect_to(standard_skill_routine_path(@routine))
    end
  end
end
