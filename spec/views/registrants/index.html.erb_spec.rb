require 'spec_helper'

describe "registrants/index" do
  before(:each) do
    assign(:registrants, [
      stub_model(Registrant,
        :first_name => "First Name",
        :middle_initial => "Middle Initial",
        :last_name => "Last Name",
        :gender => "Gender",
        :address_line_1 => "Address Line 1",
        :address_line_2 => "Address Line 2",
        :city => "City",
        :state => "State",
        :country => "Country",
        :zip_code => "Zip Code",
        :phone => "Phone",
        :mobile => "Mobile",
        :email => "Email"
      ),
      stub_model(Registrant,
        :first_name => "First Name",
        :middle_initial => "Middle Initial",
        :last_name => "Last Name",
        :gender => "Gender",
        :address_line_1 => "Address Line 1",
        :address_line_2 => "Address Line 2",
        :city => "City",
        :state => "State",
        :country => "Country",
        :zip_code => "Zip Code",
        :phone => "Phone",
        :mobile => "Mobile",
        :email => "Email"
      )
    ])
  end

  it "renders a list of registrants" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Middle Initial".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Gender".to_s, :count => 2
    assert_select "tr>td", :text => "Address Line 1".to_s, :count => 2
    assert_select "tr>td", :text => "Address Line 2".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "Country".to_s, :count => 2
    assert_select "tr>td", :text => "Zip Code".to_s, :count => 2
    assert_select "tr>td", :text => "Phone".to_s, :count => 2
    assert_select "tr>td", :text => "Mobile".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
  end
end
