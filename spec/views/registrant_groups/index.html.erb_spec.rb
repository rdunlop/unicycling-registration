require 'spec_helper'

describe "registrant_groups/index" do
  before(:each) do
    @registrant_groups = [FactoryGirl.create(:registrant_group, :name => "Name 1"),
                          FactoryGirl.create(:registrant_group, :name => "Name 2")]
    @registrant_group = FactoryGirl.create(:registrant_group)
  end

  it "renders a list of registrant_groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name 1".to_s, :count => 1
    assert_select "tr>td", :text => "Name 2".to_s, :count => 1
  end
end
