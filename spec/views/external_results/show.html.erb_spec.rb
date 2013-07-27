require 'spec_helper'

describe "external_results/show" do
  before(:each) do
    @external_result = assign(:external_result, stub_model(ExternalResult,
      :competitor_id => 1,
      :details => "Details",
      :rank => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Details/)
    rendered.should match(/2/)
  end
end
