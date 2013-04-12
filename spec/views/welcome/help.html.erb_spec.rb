require 'spec_helper'

describe "welcome/help.html.erb" do
  it "should have some help" do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @contact_form = ContactForm.new
    render
    rendered.should match(/Help/)
  end
  it "should be able to display when not signed in" do
    @contact_form = ContactForm.new
    render
    rendered.should match(/Help/)
  end
end
