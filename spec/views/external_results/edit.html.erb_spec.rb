require 'spec_helper'

describe "external_results/edit" do
  before(:each) do
    @external_result = FactoryGirl.create(:external_result)
  end

  it "renders the edit external_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => external_result_path(@external_result), :method => "put" do
      assert_select "input#external_result_competitor_id", :name => "external_result[competitor_id]"
      assert_select "input#external_result_details", :name => "external_result[details]"
      assert_select "input#external_result_rank", :name => "external_result[rank]"
    end
  end
end
