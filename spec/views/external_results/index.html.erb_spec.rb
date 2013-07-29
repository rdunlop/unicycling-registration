require 'spec_helper'

describe "external_results/index" do
  before(:each) do
    @competition = FactoryGirl.create(:competition)
    assign(:competition, @competition)
    assign(:external_results, [
        FactoryGirl.create(:external_result, :details => "Hello", :rank => 10),
        FactoryGirl.create(:external_result, :details => "Goodbye", :rank => 20)])
    @external_result = FactoryGirl.build(:external_result)
  end

  it "renders a list of external_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Hello".to_s, :count => 1
    assert_select "tr>td", :text => 10.to_s, :count => 1
    assert_select "tr>td", :text => "Goodbye".to_s, :count => 1
    assert_select "tr>td", :text => 20.to_s, :count => 1
  end
  describe "external_results/new" do
    before(:each) do
        @external_result = ExternalResult.new
    end

    it "renders new external_result form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => competition_external_results_path(@competition), :method => "post" do
        assert_select "select#external_result_competitor_id", :name => "external_result[competitor_id]"
        assert_select "input#external_result_details", :name => "external_result[details]"
        assert_select "input#external_result_rank", :name => "external_result[rank]"
      end
    end
  end
end
