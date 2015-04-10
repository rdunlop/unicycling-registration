require 'spec_helper'

describe "convention_setup/expense_groups/edit" do
  before(:each) do
    @expense_group = assign(:expense_group, FactoryGirl.build_stubbed(:expense_group))
  end

  it "renders the edit expense_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => expense_groups_path(@expense_group), :method => "post" do
      assert_select "input#expense_group_group_name", :name => "expense_group[group_name]"
      assert_select "input#expense_group_info_url", :name => "expense_group[info_url]"
    end
  end
end
