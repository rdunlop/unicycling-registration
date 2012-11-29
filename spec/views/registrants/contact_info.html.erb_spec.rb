require 'spec_helper'

describe "registrants/contact_info" do
  before(:each) do
    @registrant = FactoryGirl.create(:competitor)
    @registration_period = FactoryGirl.create(:registration_period, 
                                              :start_date => Date.new(2012, 01, 10),
                                              :end_date => Date.new(2012, 02, 11),
                                              :competitor_cost => 100,
                                              :noncompetitor_cost => 50)
  end

  it "renders new contact_info form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registrant_path(@registrant), :method => "put" do
      assert_select "input#registrant_address_line_1", :name => "registrant[address_line_1]"
      assert_select "input#registrant_address_line_2", :name => "registrant[address_line_2]"
      assert_select "input#registrant_city", :name => "registrant[city]"
      assert_select "input#registrant_state", :name => "registrant[state]"
      assert_select "input#registrant_country", :name => "registrant[country]"
      assert_select "input#registrant_zip_code", :name => "registrant[zip_code]"
      assert_select "input#registrant_phone", :name => "registrant[phone]"
      assert_select "input#registrant_mobile", :name => "registrant[mobile]"
      assert_select "input#registrant_email", :name => "registrant[email]"
    end
  end
  it "displays the 'Save Registration' button" do
    render
    assert_select "input[value='Save Registration']", 1
  end
end
