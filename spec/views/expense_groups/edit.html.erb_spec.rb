require 'spec_helper'

describe "expense_groups/edit" do
  before(:each) do
    @expense_group = assign(:expense_group, stub_model(ExpenseGroup,
      :group_name => "MyString",
      :visible => false,
      :position => 1
    ))
  end

  it "renders the edit expense_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => expense_groups_path(@expense_group), :method => "post" do
      assert_select "input#expense_group_group_name", :name => "expense_group[group_name]"
      assert_select "input#expense_group_visible", :name => "expense_group[visible]"
      assert_select "input#expense_group_position", :name => "expense_group[position]"
    end
  end
end
