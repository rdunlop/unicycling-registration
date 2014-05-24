require 'spec_helper'

describe AgeGroupEntriesController do
  before(:each) do
    sign_in FactoryGirl.create(:admin_user)
    @age_group_type = FactoryGirl.create(:age_group_type)
    @ws = FactoryGirl.create(:wheel_size)
  end

  describe "GET index" do
    it "assigns all age_group_entries as @age_group_entries" do
      age_group_entry = FactoryGirl.create(:age_group_entry, :age_group_type => @age_group_type)
      get :index, {:age_group_type_id => @age_group_type.id}
      assigns(:age_group_entries).should eq([age_group_entry])
    end
  end
end
