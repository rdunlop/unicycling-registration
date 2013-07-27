require 'spec_helper'

describe "external_results/index" do
  before(:each) do
    assign(:external_results, [
      stub_model(ExternalResult,
        :competitor_id => 1,
        :details => "Details",
        :rank => 2
      ),
      stub_model(ExternalResult,
        :competitor_id => 1,
        :details => "Details",
        :rank => 2
      )
    ])
  end

  it "renders a list of external_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Details".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
