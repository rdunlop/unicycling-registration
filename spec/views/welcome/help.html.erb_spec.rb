require 'spec_helper'

describe "welcome/help" do
  before :each do
    allow(view).to receive(:recaptcha_required?).and_return(false)
    assign(:tenant, FactoryGirl.create(:tenant))
  end

  it "should have some help" do
    @user = FactoryGirl.create(:user)
    sign_in @user
    render
    expect(rendered).to match(/Help/)
  end

  it "should be able to display when not signed in" do
    render
    expect(rendered).to match(/Help/)
  end
end
