require 'spec_helper'

describe "import_results/index" do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    assign(:user, @user)
    @competition = FactoryGirl.create(:ranked_competition)
    assign(:competition, @competition)
    assign(:import_results,
           [ FactoryGirl.create(:import_result, :details => "Raw 1", :competition => @competition, status: "DQ"),
             FactoryGirl.create(:import_result, :details => "Raw 2", :competition => @competition)])
    @import_result = FactoryGirl.build(:import_result)
  end

  it "renders a list of import_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Raw 1".to_s, :count => 1
    assert_select "tr>td", :text => "Raw 2".to_s, :count => 1
    assert_select "tr>td", :text => "Yes".to_s, :count => 1 # for dq
  end
end
