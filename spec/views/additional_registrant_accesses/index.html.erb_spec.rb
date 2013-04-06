require 'spec_helper'

describe "additional_registrant_accesses/index" do
  before(:each) do
    @reg1 = FactoryGirl.create(:registrant, :first_name => "Bob")
    @reg2 = FactoryGirl.create(:registrant, :first_name => "Jane")
    @user = FactoryGirl.create(:user)
    @additional_registrant_accesses = [
      FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg1),
      FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg2)
    ]
  end

  it "renders a list of additional_registrant_accesses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => @reg1.to_s, :count => 1
    assert_select "tr>td", :text => @reg2.to_s, :count => 1
  end
end
