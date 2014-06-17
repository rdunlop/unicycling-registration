require 'spec_helper'

describe "external_results/index" do
  before(:each) do
    @competition = FactoryGirl.build_stubbed(:ranked_competition)
    assign(:competition, @competition)
    @external_results = [
        FactoryGirl.build_stubbed(:external_result, :details => "Hello", :points => 10),
        FactoryGirl.build_stubbed(:external_result, :details => "Goodbye", :points => 20)]
    assign(:external_results, @external_results)
    @external_result = FactoryGirl.build(:external_result)
    allow(@competition).to receive(:external_results).and_return(@external_results)
    allow(@external_results[0].competitor).to receive(:place).and_return(1)
    allow(@external_results[1].competitor).to receive(:place).and_return(2)
    allow(@external_results[0].competitor).to receive(:competition).and_return(@competition)
    allow(@external_results[1].competitor).to receive(:competition).and_return(@competition)
    allow(@external_results[0].competitor).to receive(:age_group_entry_description).and_return("A")
    allow(@external_results[1].competitor).to receive(:age_group_entry_description).and_return("B")
  end

  it "renders a list of external_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Hello".to_s, :count => 1
    assert_select "tr>td", :text => "10.0", :count => 1
    assert_select "tr>td", :text => "Goodbye".to_s, :count => 1
    assert_select "tr>td", :text => "20.0", :count => 1
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
        assert_select "input#external_result_points", :name => "external_result[points]"
      end
    end
  end
end
