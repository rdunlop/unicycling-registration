require 'spec_helper'

describe "import_results/show" do
  before(:each) do
    @import_result = assign(:import_result, stub_model(ImportResult,
      :raw_data => "Raw Data",
      :bib_number => 1,
      :minutes => 2,
      :second => 3,
      :thousands => 4,
      :disqualified => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Raw Data/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/false/)
  end
end
