require 'spec_helper'

describe Event do
  before(:each) do
    @cf = ContactForm.new
  end
  it "is not valid without feedback" do
    @cf.email = "robin@dunlopweb.com"
    expect(@cf.valid?).to eq(false)
    @cf.feedback = "hi"
    expect(@cf.valid?).to eq(true)
  end

  it "is not valid without mail" do
    @cf.feedback = "hi"
    expect(@cf.valid?).to eq(false)
    @cf.email = "robin@dunlopweb.com"
    expect(@cf.valid?).to eq(true)
  end

  it "returns a default username" do
    expect(@cf.username).to eq("not-signed-in")
  end

  it "can overwrite the username" do
    @cf.username = "robin"
    expect(@cf.username).to eq("robin")
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
    expect(@cf.registrants).to eq("unknown")
  end

  it "can overwrite registrants" do
    @cf.registrants = "my registrants"
    expect(@cf.registrants).to eq("my registrants")
  end

  it "can be updated by a user object" do
    @reg = FactoryGirl.create(:competitor, first_name: "Bob", last_name: "Smith")
    @cf.update_from_user(@reg.user)
    expect(@cf.username).to eq(@reg.user.email)
    expect(@cf.registrants).to eq("Bob Smith")
  end

  it "returns the email if set for replyto" do
    @cf.email = "robin@dunlopweb.com"
    expect(@cf.reply_to_email).to eq("robin@dunlopweb.com")
  end

  it "returns the username if the email is not set for replyto" do
    @cf.email = ""
    @cf.username = "bob@dunlopweb.com"
    expect(@cf.reply_to_email).to eq("bob@dunlopweb.com")
  end
end
