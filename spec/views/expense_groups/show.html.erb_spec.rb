require 'spec_helper'

describe "expense_groups/show" do
  before(:each) do
    @expense_group = assign(:expense_group, stub_model(ExpenseGroup,
      :group_name => "Group Name",
      :visible => false,
      :position => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Group Name/)
    rendered.should match(/false/)
    rendered.should match(/1/)
  end
end
