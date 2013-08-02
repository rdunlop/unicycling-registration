require 'spec_helper'

describe "registrant_groups/show" do
  before(:each) do
    @registrant_group = assign(:registrant_group, stub_model(RegistrantGroup,
      :name => "Name",
      :registrant_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
  end
end
