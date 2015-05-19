require 'spec_helper'

describe "convention_setup/expense_items/index" do
  before(:each) do
    @group1 = FactoryGirl.create(:expense_group, :group_name => "Group 1")
    @group2 = FactoryGirl.create(:expense_group, :group_name => "Group 2")
    @item1 = FactoryGirl.create(:expense_item,
                                :name => "First",
                                :cost => 9.99,
                                :position => 1,
                                :expense_group => @group1)
    @item2 = FactoryGirl.create(:expense_item,
                                :name => "Second",
                                :cost => 31.99,
                                :position => 2,
                                :expense_group => @group2)
    @expense_items = [ @item1, @item2 ]
    @expense_item = ExpenseItem.new expense_group: @group1
    @expense_group = @group1
  end

  it "renders a list of expense_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "table#list" do
      assert_select "tr>td", :text => "First".to_s, :count => 1
      assert_select "tr>td", :text => "9.99".to_s, :count => 2 # one for the cost, one for total_cost
    end
  end

  it "renders new expense_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => expense_group_expense_items_path(@expense_group), :method => "post" do
      assert_select "input#expense_item_cost", :name => "expense_item[cost]"
      assert_select "input#expense_item_has_details", :name => "expense_item[has_details]"
    end
  end
end
