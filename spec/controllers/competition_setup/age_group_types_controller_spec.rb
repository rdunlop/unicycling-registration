require 'spec_helper'

describe CompetitionSetup::AgeGroupTypesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  def valid_attributes
    {
      name: "Default Age Group"
    }
  end

  describe "GET 'index'" do
    it "returns http success" do
      agt = FactoryGirl.create(:age_group_type)
      get :index
      expect(response).to be_success

      assert_select "h1", "Age Group Types"

      assert_select "td", agt.name
    end
  end

  describe "GET show" do
    it "shows all age_group_entries" do
      age_group_type = FactoryGirl.create(:age_group_type)
      age = FactoryGirl.create(:age_group_entry, age_group_type: age_group_type, short_description: "hi there")
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
      agt = FactoryGirl.create(:age_group_type)
      expect do
        delete :destroy, params: { id: agt.id }
      end.to change(AgeGroupType, :count).by(-1)
      expect(response).to redirect_to(age_group_types_path)
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      agt = FactoryGirl.create(:age_group_type)
      put :update, params: { id: agt.id, age_group_type: valid_attributes }
      expect(response).to redirect_to(age_group_types_path)
    end
  end
end
