require 'spec_helper'

describe "registrant_groups/show" do
  before(:each) do
    @registrant_group = assign(:registrant_group, FactoryGirl.build_stubbed(:registrant_group,
                                                                            name: "Name",
                                                                            registrant_id: 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
  end
end
