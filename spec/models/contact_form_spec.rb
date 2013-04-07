require 'spec_helper'

describe Event do
  before(:each) do
    @cf = ContactForm.new
  end
  it "is not valid without feedback" do
    @cf.valid?.should == false
    @cf.feedback = "hi"
    @cf.valid?.should == true
  end

  it "returns a default username" do
    @cf.username.should == "not-signed-in"
  end

  it "can overwrite the username" do
    @cf.username = "robin"
    @cf.username.should == "robin"
  end

  it "has default registrants" do
    @cf.registrants.should == "unknown"
  end
  
  it "can overwrite registrants" do
    @cf.registrants= "my registrants"
    @cf.registrants.should == "my registrants"
  end

  it "can be updated by a user object" do
    @reg = FactoryGirl.create(:competitor, :first_name => "Bob", :last_name => "Smith")
    @cf.update_from_user(@reg.user)
    @cf.username.should == @reg.user.email
    @cf.registrants.should == "Bob Smith"
  end
end
