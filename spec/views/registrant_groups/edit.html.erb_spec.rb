require 'spec_helper'

describe "registrant_groups/edit" do
  before(:each) do
    @registrant_group = FactoryGirl.create(:registrant_group)
  end

  it "renders the edit registrant_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registrant_groups_path(@registrant_group), :method => "post" do
      assert_select "input#registrant_group_name", :name => "registrant_group[name]"
      assert_select "select#registrant_group_registrant_id", :name => "registrant_group[registrant_id]"
    end
  end
end
