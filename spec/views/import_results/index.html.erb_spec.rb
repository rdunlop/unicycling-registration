require 'spec_helper'

describe "import_results/index" do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    assign(:user, @user)
    @competition = FactoryGirl.create(:competition)
    assign(:competition, @competition)
    assign(:import_results,
           [ FactoryGirl.create(:import_result, :raw_data => "Raw 1", :competition => @competition),
             FactoryGirl.create(:import_result, :raw_data => "Raw 2", :competition => @competition)])
    @import_result = FactoryGirl.build(:import_result)
  end

  it "renders a list of import_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Raw 1".to_s, :count => 1
    assert_select "tr>td", :text => "Raw 2".to_s, :count => 1
    assert_select "tr>td", :text => false.to_s, :count => 2 # 2 for dq
  end
end
