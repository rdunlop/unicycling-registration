# == Schema Information
#
# Table name: standard_skill_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer          not null
#  judge_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_standard_skill_scores_on_competitor_id               (competitor_id)
#  index_standard_skill_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id) UNIQUE
#

require 'spec_helper'

describe StandardSkillScoresController do
  before do
    @admin = FactoryGirl.create(:super_admin_user)
    @user = FactoryGirl.create(:data_entry_volunteer_user)
    @other_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @admin

    @judge = FactoryGirl.create(:judge, user_id: @user.id)

    @comp = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @comp2 = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @judge.competition.competitors << @comp2
    @judge.competition.competitors << @comp
    @judge.save!
  end
  let!(:routine) { FactoryGirl.create(:standard_skill_routine, registrant: @comp.registrants.first) }
  let!(:skill_1) { FactoryGirl.create(:standard_skill_routine_entry, standard_skill_routine: routine) }
  let!(:skill_2) { FactoryGirl.create(:standard_skill_routine_entry, standard_skill_routine: routine) }

  # This should return the minimal set of attributes required to create a valid
  # Score. As you add validations to Score, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      standard_skill_score_entries_attributes: [
        FactoryGirl.attributes_for(:standard_skill_score_entry, standard_skill_routine_entry_id: skill_1.id),
        FactoryGirl.attributes_for(:standard_skill_score_entry, standard_skill_routine_entry_id: skill_2.id)
      ]
    }
  end

  describe "GET index" do
    it "shows all competitors" do
      get :index, params: { judge_id: @judge.id }
      expect(response).to be_success
      assert_match(/#{@comp.registrants.first.first_name}/, response.body)
      assert_match(/#{@comp2.registrants.first.first_name}/, response.body)
    end
  end

  describe "GET new" do
    it "creates a new standard_skill_score with 2 entries" do
      get :new, params: { judge_id: @judge.id, competitor_id: @comp.id }

      assert_match(skill_1.standard_skill_entry.description, response.body)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "can create a standard_skill_score" do
        expect do
          post :create, params: { judge_id: @judge.id,  competitor_id: @comp.id, standard_skill_score: valid_attributes }
        end.to change(StandardSkillScore, :count).by(1)
      end

      it "creates score_entries too" do
        expect do
          post :create, params: { judge_id: @judge.id,  competitor_id: @comp.id, standard_skill_score: valid_attributes }
        end.to change(StandardSkillScoreEntry, :count).by(2)
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(StandardSkillScore).to receive(:valid?).and_return(false)
        post :create, params: { judge_id: @judge.id, competitor_id: @comp.id, standard_skill_score: valid_attributes }

        assert_select "h1", "New Score"
      end
    end
  end
end
