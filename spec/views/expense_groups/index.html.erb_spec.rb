require 'spec_helper'

describe "expense_groups/index" do
  before(:each) do
    @expense_group = ExpenseGroup.new
    assign(:expense_groups, [
      stub_model(ExpenseGroup,
        :group_name => "Group Name",
        :visible => false,
        :info_url => "hello world",
        :position => 1
      ),
      stub_model(ExpenseGroup,
        :group_name => "Group Name",
        :visible => false,
        :position => 1
      )
    ])
  end

  it "renders a list of expense_groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Group Name".to_s, :count => 2
    assert_select "tr>td", :text => "hello world".to_s, :count => 1
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
