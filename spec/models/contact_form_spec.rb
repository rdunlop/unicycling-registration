require 'spec_helper'

describe Event do
  before(:each) do
    @cf = ContactForm.new
  end
  it "is not valid without feedback" do
    @cf.email = "robin@dunlopweb.com"
    @cf.valid?.should == false
    @cf.feedback = "hi"
    @cf.valid?.should == true
  end

  it "is not valid without mail" do
    @cf.feedback = "hi"
    @cf.valid?.should == false
    @cf.email = "robin@dunlopweb.com"
    @cf.valid?.should == true
  end

  it "returns a default username" do
    @cf.username.should == "not-signed-in"
  end

  it "can overwrite the username" do
    @cf.username = "robin"
    @cf.username.should == "robin"
  end

  it "must specify e-mail when not signed in" do
    @cf.feedback = "This is a great site"
    expect(@cf).to be_invalid
    expect(@cf.errors).to include(:email)
  end

  it "doensn't need to specify e-mail when signed in" do
    @user = FactoryGirl.create(:user)
    @cf.update_from_user(@user)
    @cf.feedback = "This is a great site"
    expect(@cf).to be_valid
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
