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

describe Admin::StandardSkillRoutinesController do
  describe "as super_admin" do
    before do
      FactoryGirl.create(:event_configuration, standard_skill: true, standard_skill_closed_date: 1.week.from_now)
      @super_admin_user = FactoryGirl.create(:super_admin_user)
      sign_in @super_admin_user
    end

    describe "GET download_file" do
      before do
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
