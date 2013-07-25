require 'spec_helper'

describe "import_results/index" do
  before(:each) do
    assign(:import_results, [
      stub_model(ImportResult,
        :raw_data => "Raw Data",
        :bib_number => 1,
        :minutes => 2,
        :second => 3,
        :thousands => 4,
        :disqualified => false
      ),
      stub_model(ImportResult,
        :raw_data => "Raw Data",
        :bib_number => 1,
        :minutes => 2,
        :second => 3,
        :thousands => 4,
        :disqualified => false
      )
    ])
  end

  it "renders a list of import_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Raw Data".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
