require 'spec_helper'

describe PublishedAgeGroupEntriesController do
  render_views

  let(:age_group_type) { FactoryBot.create(:age_group_type) }
  let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }
  let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Ages 0-10", start_age: 0, end_age: 10) }
  let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Ages 11-20", start_age: 11, end_age: 20) }
  let(:combination) { competition.age_group_combinations.first }

  before do
    new_combination = competition.age_group_combinations.create!
    new_combination.age_group_combination_entries.create!(age_group_entry: entry_1)
    new_combination.age_group_combination_entries.create!(age_group_entry: entry_2)
  end

  describe "GET show" do
    it "shows the results of a published combination" do
      published_age_group_entry = competition.published_age_group_entries.create!(age_group: combination)

      get :show, params: { competition_id: competition.id, id: published_age_group_entry.id }

      expect(response).to be_successful
    end
  end

  describe "GET preview" do
    before { sign_in FactoryBot.create(:super_admin_user) }

    it "previews the results of a combination" do
      get :preview, params: { competition_id: competition.id, id: combination.to_age_group_param }

      expect(response).to be_successful
    end

    it "does not preview a combined entry on its own" do
      expect do
        get :preview, params: { competition_id: competition.id, id: entry_1.to_age_group_param }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
