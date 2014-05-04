require 'spec_helper'

describe "import_results/index" do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    assign(:user, @user)
    @competition = FactoryGirl.create(:competition)
    assign(:competition, @competition)
    assign(:import_results,
           [ FactoryGirl.create(:import_result, :raw_data => "Raw 1", :competition => @competition),
             FactoryGirl.create(:import_result, :raw_data => "Raw 2", :competition => @competition)])
    @import_result = FactoryGirl.build(:import_result)
  end

  it "renders a list of import_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Raw 1".to_s, :count => 1
    assert_select "tr>td", :text => "Raw 2".to_s, :count => 1
    assert_select "tr>td", :text => false.to_s, :count => 4 # 2 for dq, 2 for is_start_time
  end
  describe "import_results/new" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      assign(:user, @user)
      assign(:import_result, FactoryGirl.build(:import_result))
    end

    it "renders new import_result form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => user_competition_import_results_path(@user, @competition), :method => "post" do
        assert_select "input#import_result_raw_data", :name => "import_result[raw_data]"
        assert_select "input#import_result_bib_number", :name => "import_result[bib_number]"
        assert_select "input#import_result_minutes", :name => "import_result[minutes]"
        assert_select "input#import_result_seconds", :name => "import_result[seconds]"
        assert_select "input#import_result_thousands", :name => "import_result[thousands]"
        assert_select "input#import_result_disqualified", :name => "import_result[disqualified]"
      end
    end
  end
end
