require 'spec_helper'

describe "welcome/help.html.erb" do
  it "should have some help" do
    @contact_form = ContactForm.new
    render
    rendered.should match(/Help/)
  end
end
