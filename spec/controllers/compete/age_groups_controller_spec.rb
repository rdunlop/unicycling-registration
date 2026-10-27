require 'spec_helper'

describe Compete::AgeGroupsController do
  before do
    @admin_user = FactoryBot.create(:super_admin_user)
    sign_in @admin_user
  end

  let(:age_group_type) { FactoryBot.create(:age_group_type) }
  let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }
  let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 0, end_age: 10) }
  let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 11, end_age: 20) }

  describe "GET show" do
    render_views

    it "renders" do
      AgeGroupCombiner.new(competition).combine(entry_1, entry_2)

      get :show, params: { competition_id: competition.id }
      expect(response).to be_successful
      expect(response.body).to include("Rename", "cannot be modified")
      combination = competition.age_group_combinations.first
      assert_select ".js--inlineEdit" do
        assert_select ".js--inlineEditDisplay", text: /#{Regexp.escape(combination.to_s)}/
        assert_select "form.js--inlineEditForm.is--hidden input[name=name][value=?]", combination.short_description
      end
    end
  end

  describe "PUT combine" do
    it "combines the age groups" do
      expect do
        put :combine, params: { competition_id: competition.id, age_groups: [entry_1.to_age_group_param, entry_2.to_age_group_param] }
      end.to change(AgeGroupCombination, :count).by(1)
      expect(response).to redirect_to(competition_age_groups_path(competition))
    end

    it "does not combine with a missing age group" do
      expect do
        put :combine, params: { competition_id: competition.id, age_groups: [entry_1.to_age_group_param] }
      end.not_to change(AgeGroupCombination, :count)
      expect(flash[:alert]).to be_present
    end
  end

  describe "PUT rename" do
    it "renames the combination" do
      AgeGroupCombiner.new(competition).combine(entry_1, entry_2)
      combination = competition.age_group_combinations.first

      put :rename, params: { competition_id: competition.id, age_group_combination_id: combination.id, name: "Juniors" }

      expect(combination.reload.name).to eq("Juniors")
      expect(response).to redirect_to(competition_age_groups_path(competition))
    end
  end

  describe "PUT separate" do
    it "separates the combination" do
      AgeGroupCombiner.new(competition).combine(entry_1, entry_2)
      combination = competition.age_group_combinations.first

      expect do
        put :separate, params: { competition_id: competition.id, age_group_combination_id: combination.id }
      end.to change(AgeGroupCombination, :count).by(-1)
      expect(AgeGroupEntry.count).to eq(2)
    end
  end
end
