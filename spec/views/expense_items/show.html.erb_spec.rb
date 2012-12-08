require 'spec_helper'

describe "expense_items/show" do
  before(:each) do
    @expense_item = assign(:expense_item, stub_model(ExpenseItem,
      :name => "Name",
      :description => "Description",
      :cost => "9.99",
      :export_name => "Export Name",
      :position => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Description/)
    rendered.should match(/9.99/)
    rendered.should match(/Export Name/)
    rendered.should match(/1/)
  end
end
