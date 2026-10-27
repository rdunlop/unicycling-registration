require 'spec_helper'

describe CompetitionSetup::AgeGroupTypesController do
  before do
    sign_in FactoryBot.create(:super_admin_user)
  end

  def valid_attributes
    {
      name: "Default Age Group"
    }
  end

  describe "GET 'index'" do
    it "returns http success" do
      agt = FactoryBot.create(:age_group_type)
      get :index
      expect(response).to be_successful

      assert_select "h1", "Age Group Types"

      assert_select "td", agt.name
    end
  end

  describe "GET show" do
    it "shows all age_group_entries" do
      age_group_type = FactoryBot.create(:age_group_type)
      age = FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "hi there")
      get :show, params: { id: age_group_type.id }

      assert_select "td", age.short_description
    end
  end

  describe "POST 'create'" do
    it "creates the new age group type" do
      expect do
        post :create, params: { age_group_type: valid_attributes }
      end.to change(AgeGroupType, :count).by(1)
      expect(response).to redirect_to(age_group_types_path)
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      agt = FactoryBot.create(:age_group_type)
      expect do
        delete :destroy, params: { id: agt.id }
      end.to change(AgeGroupType, :count).by(-1)
      expect(response).to redirect_to(age_group_types_path)
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      agt = FactoryBot.create(:age_group_type)
      put :update, params: { id: agt.id, age_group_type: valid_attributes }
      expect(response).to redirect_to(age_group_types_path)
    end
  end

  describe "with combined age groups" do
    render_views

    let(:age_group_type) { FactoryBot.create(:age_group_type) }
    let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }
    let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Ages 0-10", start_age: 0, end_age: 10) }
    let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Ages 11-20", start_age: 11, end_age: 20) }

    before { AgeGroupCombiner.new(competition.reload).combine(entry_1, entry_2) }

    it "shows the combinations, linking to their competition" do
      get :show, params: { id: age_group_type.id }

      assert_select ".callout.warning a[href=?]", competition_age_groups_path(competition), text: competition.to_s
      expect(response.body).to include("Ages 0-10 and Ages 11-20")
      assert_select "table.js--sortable", count: 0
    end

    it "does not modify the entries" do
      put :update, params: { id: age_group_type.id, age_group_type: { age_group_entries_attributes: { "0" => { id: entry_2.id, end_age: 25 } } } }

      expect(response).to be_successful
      expect(response.body).to include("cannot be modified while some of its age groups are combined")
      expect(entry_2.reload.end_age).to eq(20)
    end
  end
end
