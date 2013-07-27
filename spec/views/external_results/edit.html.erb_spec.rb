require 'spec_helper'

describe "external_results/edit" do
  before(:each) do
    @external_result = assign(:external_result, stub_model(ExternalResult,
      :competitor_id => 1,
      :details => "MyString",
      :rank => 1
    ))
  end

  it "renders the edit external_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => external_results_path(@external_result), :method => "post" do
      assert_select "input#external_result_competitor_id", :name => "external_result[competitor_id]"
      assert_select "input#external_result_details", :name => "external_result[details]"
      assert_select "input#external_result_rank", :name => "external_result[rank]"
    end
  end
end
