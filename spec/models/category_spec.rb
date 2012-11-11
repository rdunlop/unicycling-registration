require 'spec_helper'

describe Category do
  it "must have a name" do
    cat = Category.new
    cat.valid?.should == false
    cat.name = "Track"
    cat.valid?.should == true
  end
end
