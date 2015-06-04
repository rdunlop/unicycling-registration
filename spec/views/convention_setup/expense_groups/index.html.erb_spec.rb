require 'spec_helper'

describe "convention_setup/expense_groups/index" do
  before(:each) do
    @expense_group = ExpenseGroup.new
    assign(:expense_groups, [
      FactoryGirl.build_stubbed(:expense_group, group_name: "Group Name", info_url: "hello world"),
      FactoryGirl.build_stubbed(:expense_group, group_name: "Group Name")])
  end

  it "renders a list of expense_groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: "Group Name".to_s, count: 2
  end
end
