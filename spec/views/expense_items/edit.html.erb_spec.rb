require 'spec_helper'

describe "expense_items/edit" do
  before(:each) do
    @expense_item = assign(:expense_item, FactoryGirl.build_stubbed(:expense_item))
    @expense_group = @expense_item.expense_group
  end

  it "renders the edit expense_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => expense_group_expense_items_path(@expense_group, @expense_item), :method => "post" do
      assert_select "input#expense_item_has_details", :name => "expense_item[has_details]"
      assert_select "input#expense_item_cost", :name => "expense_item[cost]"
    end
  end
end
