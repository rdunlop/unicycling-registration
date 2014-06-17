require 'spec_helper'

describe "import_results/edit" do
  describe "For a timed event" do
    let(:competition) { FactoryGirl.build_stubbed(:timed_competition) }
    before(:each) do
      @import_result = assign(:import_result, FactoryGirl.build_stubbed(:import_result, competition: competition))
    end

    it "renders the edit import_result form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => import_result_path(@import_result), :method => "post" do
        assert_select "select#import_result_bib_number", :name => "import_result[bib_number]"
        assert_select "input#import_result_minutes", :name => "import_result[minutes]"
        assert_select "input#import_result_seconds", :name => "import_result[seconds]"
        assert_select "input#import_result_thousands", :name => "import_result[thousands]"
        assert_select "select#import_result_status", :name => "import_result[status]"
      end
    end
  end

  describe "for a ranked competition" do
    let(:competition) { FactoryGirl.build_stubbed(:ranked_competition) }
    before :each do
      @import_result = assign(:import_result, FactoryGirl.build_stubbed(:import_result, competition: competition))
    end

    it "renders the edit import_result form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => import_result_path(@import_result), :method => "post" do
        assert_select "select#import_result_bib_number", :name => "import_result[bib_number]"
        assert_select "input#import_result_raw_data", :name => "import_result[raw_data]"
      end
    end
  end
end
