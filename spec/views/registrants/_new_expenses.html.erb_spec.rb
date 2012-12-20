require 'spec_helper'

describe "registrants/_new_expenses" do
  before(:each) do
    @group = FactoryGirl.create(:expense_group)
    @item1 = FactoryGirl.create(:expense_item, :expense_group => @group)
    @item2 = FactoryGirl.create(:expense_item, :expense_group => @group)

    @group2 = FactoryGirl.create(:expense_group, :position => 2, :visible => false)
    @item3 = FactoryGirl.create(:expense_item, :expense_group => @group2)
    @item4 = FactoryGirl.create(:expense_item, :expense_group => @group2)
  end

  it "renders group header" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "fieldset", 1 do
      assert_select "legend", :text => "Add " + @group.group_name
      assert_select "label", :text => @item1
      assert_select "label", :text => @item3, :count => 0
    end
  end
end
