require 'spec_helper'

describe "import_results/new" do
  before(:each) do
    assign(:import_result, stub_model(ImportResult,
      :raw_data => "MyString",
      :bib_number => 1,
      :minutes => 1,
      :second => 1,
      :thousands => 1,
      :disqualified => false
    ).as_new_record)
  end

  it "renders new import_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => import_results_path, :method => "post" do
      assert_select "input#import_result_raw_data", :name => "import_result[raw_data]"
      assert_select "input#import_result_bib_number", :name => "import_result[bib_number]"
      assert_select "input#import_result_minutes", :name => "import_result[minutes]"
      assert_select "input#import_result_second", :name => "import_result[second]"
      assert_select "input#import_result_thousands", :name => "import_result[thousands]"
      assert_select "input#import_result_disqualified", :name => "import_result[disqualified]"
    end
  end
end
