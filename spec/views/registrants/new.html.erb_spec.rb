require 'spec_helper'

describe "registrants/new" do
  before(:each) do
    @registrant = FactoryGirl.create(:competitor)
    @registration_period = FactoryGirl.create(:registration_period, 
                                              :start_date => Date.new(2012, 01, 10),
                                              :end_date => Date.new(2012, 02, 11),
                                              :competitor_cost => 100,
                                              :noncompetitor_cost => 50)
  end

  it "renders new registrant form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registrants_path, :method => "post" do
      assert_select "input#registrant_first_name", :name => "registrant[first_name]"
      assert_select "input#registrant_middle_initial", :name => "registrant[middle_initial]"
      assert_select "input#registrant_last_name", :name => "registrant[last_name]"
      assert_select "input#registrant_gender_male", :name => "registrant[gender]"
      assert_select "input#registrant_address_line_1", :name => "registrant[address_line_1]"
      assert_select "input#registrant_address_line_2", :name => "registrant[address_line_2]"
      assert_select "input#registrant_city", :name => "registrant[city]"
      assert_select "input#registrant_state", :name => "registrant[state]"
      assert_select "input#registrant_country", :name => "registrant[country]"
      assert_select "input#registrant_zip_code", :name => "registrant[zip_code]"
      assert_select "input#registrant_phone", :name => "registrant[phone]"
      assert_select "input#registrant_mobile", :name => "registrant[mobile]"
      assert_select "input#registrant_competitor", :name => "registrant[competitor]"
      assert_select "input#registrant_email", :name => "registrant[email]"
    end
  end
  it "renders dates in nice formats" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Jan 10, 2012/)
    rendered.should match(/Feb 11, 2012/)
  end
  it "lists competitor costs" do
    render
    rendered.should match(/\$100/)
  end
  it "displays the 'Next Page' button" do
    render
    assert_select "input[value='Next Page']", 1
  end

  describe "as non-competitor" do
    before(:each) do
      @registrant.competitor = false
    end
    it "displays the words Non-Competitor" do
      render
      assert_select "h2", :text => "Non-Competitor"
    end
    it "displays the registration_period for non-competitors" do
      render
      rendered.should match(/\$50/)
    end
    it "displays the 'Save Registration' button" do
      render
      assert_select "input[value='Save Registration']", 1
    end
  end
end
