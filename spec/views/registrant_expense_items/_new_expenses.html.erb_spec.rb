require 'spec_helper'

describe "registrant_expense_items/_new_expenses" do
  before(:each) do
    @group = FactoryGirl.build_stubbed(:expense_group)
    @item1 = FactoryGirl.build_stubbed(:expense_item, expense_group: @group)
    @item2 = FactoryGirl.build_stubbed(:expense_item, expense_group: @group)
    allow(@group).to receive(:expense_items).and_return([@item1, @item2])

    @group2 = FactoryGirl.build_stubbed(:expense_group, position: 2, visible: false)
    @item3 = FactoryGirl.build_stubbed(:expense_item, expense_group: @group2)
    @item4 = FactoryGirl.build_stubbed(:expense_item, expense_group: @group2)
    allow(@group2).to receive(:expense_items).and_return([@item3, @item4])

    expect(ExpenseGroup).to receive_message_chain(:admin_visible, :includes).and_return([@group])
    @registrant = FactoryGirl.build_stubbed(:competitor)
  end

  it "renders group header" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "fieldset", 1 do
      assert_select "legend", text: "Add " + @group.group_name
      assert_select "td", text: @item1.name
      assert_select "td", text: @item3.name, count: 0
    end
  end
end
