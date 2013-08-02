require 'spec_helper'

describe "registrant_groups/index" do
  before(:each) do
    assign(:registrant_groups, [
      stub_model(RegistrantGroup,
        :name => "Name",
        :registrant_id => 1
      ),
      stub_model(RegistrantGroup,
        :name => "Name",
        :registrant_id => 1
      )
    ])
  end

  it "renders a list of registrant_groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
