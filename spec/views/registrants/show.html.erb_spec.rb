require 'spec_helper'

describe "registrants/show" do
  before(:each) do
    @registrant = FactoryGirl.create(:registrant, :birthday => Date.new(2012, 01, 05))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/#{@registrant.first_name}/)
    rendered.should match(/#{@registrant.last_name}/)
    rendered.should match(/#{@registrant.gender}/)
    rendered.should match(/05-Jan-2012/)
    rendered.should match(/#{@registrant.address}/)
    rendered.should match(/#{@registrant.city}/)
    rendered.should match(/#{@registrant.state}/)
    rendered.should match(/#{@registrant.zip}/)
    rendered.should match(/#{@registrant.country}/)
    rendered.should match(/#{@registrant.phone}/)
    rendered.should match(/#{@registrant.mobile}/)
    rendered.should match(/#{@registrant.email}/)
    rendered.should match(/#{@registrant.club}/)
    rendered.should match(/#{@registrant.club_contact}/)
    rendered.should match(/#{@registrant.usa_member_number}/)
    rendered.should match(/#{@registrant.emergency_name}/)
    rendered.should match(/#{@registrant.emergency_relationship}/)
    rendered.should match(/#{@registrant.emergency_attending}/)
    rendered.should match(/#{@registrant.emergency_primary_phone}/)
    rendered.should match(/#{@registrant.emergency_other_phone}/)
    rendered.should match(/#{@registrant.responsible_adult_name}/)
    rendered.should match(/#{@registrant.responsible_adult_phone}/)
  end
end
