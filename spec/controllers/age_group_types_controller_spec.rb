require 'spec_helper'

describe AgeGroupTypesController do
  before(:each) do
    sign_in FactoryGirl.create(:admin_user)
  end

  def valid_attributes
    {
      name: "Default Age Group"
    }
  end

  describe "GET 'index'" do
    it "returns http success" do
      agt = FactoryGirl.create(:age_group_type)
      get 'index'
      response.should be_success
      assigns(:age_group_types).should == [agt]
    end
  end

  describe "GET show" do
    it "assigns all age_group_entries as @age_group_entries" do
      age_group_type = FactoryGirl.create(:age_group_type)
      age_group_entry = FactoryGirl.create(:age_group_entry, :age_group_type => age_group_type)
      get :show, {:id => age_group_type.id}
      assigns(:age_group_type).should eq(age_group_type)
    end
  end

  describe "POST 'create'" do
    it "creates the new age group type" do
      expect {
        post :create, {:age_group_type => valid_attributes}
      }.to change(AgeGroupType, :count).by(1)
      response.should redirect_to(age_group_types_path)
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      agt = FactoryGirl.create(:age_group_type)
      expect {
        delete 'destroy', {:id => agt.id}
      }.to change(AgeGroupType, :count).by(-1)
      response.should redirect_to(age_group_types_path)
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      agt = FactoryGirl.create(:age_group_type)
      put 'update', {:id => agt.id, :age_group_type => valid_attributes}
      response.should redirect_to(age_group_types_path)
    end
  end

end
