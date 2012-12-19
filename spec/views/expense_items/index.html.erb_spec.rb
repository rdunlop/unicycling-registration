require 'spec_helper'

describe "expense_items/index" do
  before(:each) do
    assign(:expense_items, [
      stub_model(ExpenseItem,
        :name => "Name",
        :description => "Description",
        :cost => "9.99",
        :export_name => "Export Name",
        :position => 1
      ),
      stub_model(ExpenseItem,
        :name => "Name",
        :description => "Description",
        :cost => "9.99",
        :export_name => "Export Name",
        :position => 1
      )
    ])
    @expense_item = ExpenseItem.new
  end

  it "renders a list of expense_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Export Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end

  it "renders new expense_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => expense_items_path, :method => "post" do
      assert_select "input#expense_item_name", :name => "expense_item[name]"
      assert_select "input#expense_item_description", :name => "expense_item[description]"
      assert_select "input#expense_item_cost", :name => "expense_item[cost]"
      assert_select "input#expense_item_export_name", :name => "expense_item[export_name]"
      assert_select "input#expense_item_position", :name => "expense_item[position]"
    end
  end
end
