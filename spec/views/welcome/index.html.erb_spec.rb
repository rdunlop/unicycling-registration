require 'spec_helper'

describe "welcome/index.html.erb" do
  it "displays the welcome" do
    render
    rendered.should match(/Welcome/)
  end
end
