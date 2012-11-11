require 'spec_helper'

describe "registrants/show" do
  before(:each) do
    @registrant = assign(:registrant, stub_model(Registrant,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/First Name/)
    rendered.should match(/Middle Initial/)
    rendered.should match(/Last Name/)
    rendered.should match(/Gender/)
    rendered.should match(/Address Line 1/)
    rendered.should match(/Address Line 2/)
    rendered.should match(/City/)
    rendered.should match(/State/)
    rendered.should match(/Country/)
    rendered.should match(/Zip Code/)
    rendered.should match(/Phone/)
    rendered.should match(/Mobile/)
    rendered.should match(/Email/)
  end
end
