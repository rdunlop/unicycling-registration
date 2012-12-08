require 'spec_helper'

describe "expense_items/new" do
  before(:each) do
    assign(:expense_item, stub_model(ExpenseItem,
      :name => "MyString",
      :description => "MyString",
      :cost => "9.99",
      :export_name => "MyString",
      :position => 1
    ).as_new_record)
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
