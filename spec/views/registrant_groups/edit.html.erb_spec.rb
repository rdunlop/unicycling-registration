require 'spec_helper'

describe "registrant_groups/edit" do
  before(:each) do
    @registrant_group = assign(:registrant_group, stub_model(RegistrantGroup,
      :name => "MyString",
      :registrant_id => 1
    ))
  end

  it "renders the edit registrant_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registrant_groups_path(@registrant_group), :method => "post" do
      assert_select "input#registrant_group_name", :name => "registrant_group[name]"
      assert_select "input#registrant_group_registrant_id", :name => "registrant_group[registrant_id]"
    end
  end
end
